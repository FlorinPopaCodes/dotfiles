#!/usr/bin/env bash
# Sync untracked brew packages into categorized Brewfiles
# Usage: brew-sync.sh [-y] [--preview]

# === Configuration ===
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BREWFILE_CORE="$DOTFILES/macos/Brewfile.core"
BREWFILE_APPS="$DOTFILES/macos/Brewfile.apps"
BREWFILE_DEV="$DOTFILES/macos/Brewfile.dev"

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# === Parse arguments ===
AUTO_APPLY=false
PREVIEW_ONLY=false
SHOW_DEPS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) AUTO_APPLY=true; shift ;;
        --preview) PREVIEW_ONLY=true; shift ;;
        --deps) SHOW_DEPS=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# === Temp directory ===
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# === Data Collection (parallel) ===
echo -e "${DIM}Collecting package data...${NC}"

# Get installed packages
brew list --formula > "$tmpdir/installed_formulae" &
brew list --cask > "$tmpdir/installed_casks" &
mas list 2>/dev/null | awk '{print $1}' | sort -u > "$tmpdir/installed_mas" &

# Get leaf packages (not dependencies)
brew leaves > "$tmpdir/leaves" &

# Get package info for descriptions
brew info --json=v2 --installed > "$tmpdir/brew_info.json" 2>/dev/null &

wait

# === Parse existing Brewfiles ===
parse_brewfile() {
    local file="$1"
    local type="$2"  # brew, cask, mas, tap

    case "$type" in
        brew)
            grep -E '^brew "' "$file" 2>/dev/null | sed 's/brew "//;s/".*//' | sed 's|.*/||' || true
            ;;
        cask)
            grep -E '^cask "' "$file" 2>/dev/null | sed 's/cask "//;s/".*//' || true
            ;;
        mas)
            grep -E '^mas "' "$file" 2>/dev/null | sed 's/.*id: //' || true
            ;;
        tap)
            grep -E '^tap "' "$file" 2>/dev/null | sed 's/tap "//;s/".*//' || true
            ;;
    esac
}

# Collect tracked packages from all Brewfiles
{
    parse_brewfile "$BREWFILE_CORE" brew
    parse_brewfile "$BREWFILE_APPS" brew
    parse_brewfile "$BREWFILE_DEV" brew
} | sort -u > "$tmpdir/tracked_formulae"

{
    parse_brewfile "$BREWFILE_CORE" cask
    parse_brewfile "$BREWFILE_APPS" cask
    parse_brewfile "$BREWFILE_DEV" cask
} | sort -u > "$tmpdir/tracked_casks"

{
    parse_brewfile "$BREWFILE_CORE" mas
    parse_brewfile "$BREWFILE_APPS" mas
    parse_brewfile "$BREWFILE_DEV" mas
} | sort -u > "$tmpdir/tracked_mas"

{
    parse_brewfile "$BREWFILE_CORE" tap
    parse_brewfile "$BREWFILE_APPS" tap
    parse_brewfile "$BREWFILE_DEV" tap
} | sort -u > "$tmpdir/tracked_taps"

# === Find untracked packages ===
comm -23 <(sort "$tmpdir/installed_formulae") <(sort "$tmpdir/tracked_formulae") > "$tmpdir/untracked_formulae"
comm -23 <(sort "$tmpdir/installed_casks") <(sort "$tmpdir/tracked_casks") > "$tmpdir/untracked_casks"
comm -23 <(sort "$tmpdir/installed_mas") <(sort "$tmpdir/tracked_mas") > "$tmpdir/untracked_mas"

# === Helper functions ===

is_dependency() {
    local pkg="$1"
    ! grep -qx "$pkg" "$tmpdir/leaves"
}

get_description() {
    local pkg="$1"
    jq -r --arg name "$pkg" '
        (.formulae[] | select(.name == $name or .full_name == $name) | .desc) //
        (.casks[] | select(.token == $name) | .desc) //
        ""
    ' "$tmpdir/brew_info.json" 2>/dev/null | head -1
}

get_full_name() {
    local pkg="$1"
    jq -r --arg name "$pkg" '
        .formulae[] | select(.name == $name) | .full_name
    ' "$tmpdir/brew_info.json" 2>/dev/null | head -1
}

get_tap_from_full_name() {
    local full_name="$1"
    if [[ "$full_name" =~ ^([^/]+/[^/]+)/ ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# === Category detection ===
categorize_formula() {
    local name="$1"
    local desc="${2:-}"

    # Libraries (lib*) almost always go to dev - check first
    if [[ "$name" =~ ^lib ]]; then
        echo "dev"
        return
    fi

    # CORE patterns - exact name matches or specific patterns
    # These are CLI tools you'd use directly
    case "$name" in
        # Shell and prompt
        bash|zsh|fish|starship|zinit|antigen|oh-my-zsh|powerlevel*)
            echo "core"; return ;;
        # Navigation/search
        zoxide|autojump|fzf|fd|ripgrep|the_silver_searcher|ag)
            echo "core"; return ;;
        # File viewers
        bat|eza|exa|lsd|less|most)
            echo "core"; return ;;
        # Core utilities
        coreutils|stow|just|wget|jq|yq|htop|btop|tlrc|gtrash|mas|mosh|pam-reattach|direnv|thefuck)
            echo "core"; return ;;
        # Git tools
        git-delta|git-lfs|gh|git-absorb|gitleaks|lefthook)
            echo "core"; return ;;
        # Editors
        neovim|vim|nano|micro)
            echo "core"; return ;;
        # Security (standalone tools, not libs)
        gnupg|gpg)
            echo "core"; return ;;
    esac

    # DEV patterns - languages, build tools, dev-specific
    case "$name" in
        # Languages and runtimes
        node|python*|ruby*|rust|go|java|openjdk*|bun|deno|swift|lua|luajit)
            echo "dev"; return ;;
        # Version managers
        rbenv|pyenv|nvm|asdf|uv|pipenv|poetry)
            echo "dev"; return ;;
        # Build tools
        cmake|gcc|llvm*|make|autoconf|automake|sccache|m4)
            echo "dev"; return ;;
        # Package managers
        npm|pnpm|yarn|pip|cargo|gem)
            echo "dev"; return ;;
        # Docker/K8s
        docker|kubernetes|kubectl|kind|k9s|helm|act)
            echo "dev"; return ;;
        # Cloud
        aws*|gcloud*|azure*|flyctl|terraform|opentofu|cloudflare*)
            echo "dev"; return ;;
        # Databases
        mysql*|postgres*|redis*|mongo*|sqlite*)
            echo "dev"; return ;;
        # Media processing
        ffmpeg|imagemagick|tesseract|poppler|ghostscript|sdl*)
            echo "dev"; return ;;
        # AI tools
        openai|claude|gemini*|codex|ast-grep|opencode)
            echo "dev"; return ;;
        # Other dev tools
        protobuf|grpc|exercism|typst|yamllint|mergiraf|socat)
            echo "dev"; return ;;
    esac

    # Default to dev (most untracked packages are dev dependencies)
    echo "dev"
}

categorize_cask() {
    local name="$1"

    # Fonts go to core (user preference)
    if [[ "$name" =~ ^font- ]]; then
        echo "core"
        return
    fi

    # All other casks go to apps
    echo "apps"
}

# === Build proposed changes ===
declare -A core_additions
declare -A apps_additions
declare -A dev_additions
declare -A needed_taps

# Process formulae
dep_count=0
while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue

    # Skip dependencies unless --deps flag is set
    if is_dependency "$pkg"; then
        if ! $SHOW_DEPS; then
            ((dep_count++))
            continue
        fi
    fi

    desc=$(get_description "$pkg")
    full_name=$(get_full_name "$pkg")
    category=$(categorize_formula "$pkg" "$desc")

    # Check for tap
    tap=$(get_tap_from_full_name "$full_name")
    if [[ -n "$tap" ]] && ! grep -qx "$tap" "$tmpdir/tracked_taps"; then
        needed_taps["$tap"]="$category"
    fi

    # Use full_name if it has a tap prefix
    brew_name="$pkg"
    if [[ "$full_name" == */* ]]; then
        brew_name="$full_name"
    fi

    entry="brew \"$brew_name\""
    case "$category" in
        core) core_additions["$pkg"]="$entry|$desc|" ;;
        apps) apps_additions["$pkg"]="$entry|$desc|" ;;
        dev)  dev_additions["$pkg"]="$entry|$desc|" ;;
    esac
done < "$tmpdir/untracked_formulae"

# Process casks
while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue

    desc=$(get_description "$pkg")
    category=$(categorize_cask "$pkg")

    entry="cask \"$pkg\""
    case "$category" in
        core) core_additions["$pkg"]="$entry|$desc|" ;;
        apps) apps_additions["$pkg"]="$entry|$desc|" ;;
    esac
done < "$tmpdir/untracked_casks"

# Process mas apps
while IFS= read -r app_id; do
    [[ -z "$app_id" ]] && continue

    # Get app name from mas list (format: " 12345  AppName  (version)")
    # The ID may have leading spaces, and the name has trailing spaces
    # Use head -1 in case of duplicate entries
    app_name=$(mas list 2>/dev/null | awk -v id="$app_id" '$1 == id {
        # Remove first field (ID) and last field (version in parens)
        $1 = ""; $NF = "";
        # Trim leading/trailing whitespace
        gsub(/^[[:space:]]+|[[:space:]]+$/, "");
        print; exit
    }')
    [[ -z "$app_name" ]] && continue

    entry="mas \"$app_name\", id: $app_id"
    apps_additions["mas_$app_id"]="$entry|Mac App Store|"
done < "$tmpdir/untracked_mas"

# === Display preview ===
total_core=${#core_additions[@]}
total_apps=${#apps_additions[@]}
total_dev=${#dev_additions[@]}
total=$((total_core + total_apps + total_dev))

if [[ $total -eq 0 ]]; then
    echo -e "${GREEN}All packages are tracked! Nothing to sync.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                           BREW SYNC - UNTRACKED PACKAGES${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

print_section() {
    local title="$1"
    local file="$2"
    shift 2
    local -n items=$1

    local count=${#items[@]}
    [[ $count -eq 0 ]] && return

    echo -e "${BLUE}${BOLD}→ $title${NC} ${DIM}(+$count packages)${NC}"
    echo -e "${DIM}  Target: $file${NC}"
    echo ""

    for key in "${!items[@]}"; do
        IFS='|' read -r entry desc _ <<< "${items[$key]}"
        echo -e "  ${GREEN}$entry${NC}"
        if [[ -n "$desc" ]]; then
            echo -e "    ${DIM}$desc${NC}"
        fi
    done
    echo ""
}

# Print needed taps first
if [[ ${#needed_taps[@]} -gt 0 ]]; then
    echo -e "${CYAN}${BOLD}TAPS NEEDED:${NC}"
    for tap in "${!needed_taps[@]}"; do
        category="${needed_taps[$tap]}"
        echo -e "  ${CYAN}tap \"$tap\"${NC}  ${DIM}→ Brewfile.$category${NC}"
    done
    echo ""
fi

print_section "Brewfile.core" "$BREWFILE_CORE" core_additions
print_section "Brewfile.apps" "$BREWFILE_APPS" apps_additions
print_section "Brewfile.dev" "$BREWFILE_DEV" dev_additions

echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}Total:${NC} $total packages to add ($total_core core, $total_apps apps, $total_dev dev)"
if [[ $dep_count -gt 0 ]]; then
    echo -e "  ${DIM}($dep_count dependencies hidden - use --deps to include)${NC}"
fi
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# === Exit if preview only ===
if $PREVIEW_ONLY; then
    echo -e "${DIM}Preview only mode. No changes made.${NC}"
    exit 0
fi

# === Confirm and apply ===
if ! $AUTO_APPLY; then
    echo -en "${BOLD}Apply these changes?${NC} [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${DIM}Applying changes...${NC}"

# Add taps to appropriate files
for tap in "${!needed_taps[@]}"; do
    category="${needed_taps[$tap]}"
    target_file="$DOTFILES/macos/Brewfile.$category"

    # Add tap at the beginning of file (after any existing taps)
    if grep -q '^tap ' "$target_file" 2>/dev/null; then
        # Find last tap line and insert after it
        last_tap_line=$(grep -n '^tap ' "$target_file" | tail -1 | cut -d: -f1)
        sed -i '' "${last_tap_line}a\\
tap \"$tap\"
" "$target_file"
    else
        # No existing taps, add at the beginning
        sed -i '' "1i\\
tap \"$tap\"
" "$target_file"
    fi
    echo -e "  ${CYAN}Added tap:${NC} $tap → Brewfile.$category"
done

# Append packages to files
append_to_file() {
    local file="$1"
    local category="$2"
    shift 2
    local -n additions=$1

    [[ ${#additions[@]} -eq 0 ]] && return

    echo "" >> "$file"
    echo "# Added by brew-sync $(date +%Y-%m-%d)" >> "$file"

    for key in "${!additions[@]}"; do
        IFS='|' read -r entry desc dep_marker <<< "${additions[$key]}"
        echo "$entry" >> "$file"
        echo -e "  ${GREEN}Added:${NC} $entry → Brewfile.$category"
    done
}

append_to_file "$BREWFILE_CORE" "core" core_additions
append_to_file "$BREWFILE_APPS" "apps" apps_additions
append_to_file "$BREWFILE_DEV" "dev" dev_additions

echo ""
echo -e "${GREEN}${BOLD}Done!${NC} Added $total packages to Brewfiles."
