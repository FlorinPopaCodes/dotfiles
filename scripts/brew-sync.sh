#!/usr/bin/env bash
# Sync untracked brew packages into packages.yaml
# Usage: brew-sync.sh [-y] [--preview] [--deps]

# === Configuration ===
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
PACKAGES_YAML="$DOTFILES/.chezmoidata/packages.yaml"

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

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

if [[ ! -f "$PACKAGES_YAML" ]]; then
    echo -e "${RED}packages.yaml not found at $PACKAGES_YAML${NC}"
    exit 1
fi

# === Temp directory ===
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# === Data Collection (parallel) ===
echo -e "${DIM}Collecting package data...${NC}"

brew list --formula > "$tmpdir/installed_formulae" &
brew list --cask > "$tmpdir/installed_casks" &
mas list 2>/dev/null | awk '{print $1}' | sort -u > "$tmpdir/installed_mas" &
brew leaves > "$tmpdir/leaves" &
brew info --json=v2 --installed > "$tmpdir/brew_info.json" 2>/dev/null &
wait

# === Parse packages.yaml ===
# Extract tracked brews (strip leading "- " and quotes, extract short name)
python3 -c "
import yaml, sys
with open('$PACKAGES_YAML') as f:
    data = yaml.safe_load(f)
darwin = data.get('darwin', {})

for b in darwin.get('brews', []):
    # Short name (after last /)
    print(b.split('/')[-1])
" > "$tmpdir/tracked_formulae"

python3 -c "
import yaml, sys
with open('$PACKAGES_YAML') as f:
    data = yaml.safe_load(f)
darwin = data.get('darwin', {})

for c in darwin.get('casks', []):
    print(c)
" > "$tmpdir/tracked_casks"

python3 -c "
import yaml, sys
with open('$PACKAGES_YAML') as f:
    data = yaml.safe_load(f)
darwin = data.get('darwin', {})

for m in darwin.get('mas', []):
    print(m['id'])
" > "$tmpdir/tracked_mas"

python3 -c "
import yaml, sys
with open('$PACKAGES_YAML') as f:
    data = yaml.safe_load(f)
darwin = data.get('darwin', {})

for t in darwin.get('taps', []):
    print(t)
" > "$tmpdir/tracked_taps"

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

# === Collect untracked packages ===
declare -a new_brews=()
declare -a new_casks=()
declare -a new_taps=()
declare -a new_mas=()

dep_count=0
while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue

    if is_dependency "$pkg"; then
        if ! $SHOW_DEPS; then
            ((dep_count++))
            continue
        fi
    fi

    full_name=$(get_full_name "$pkg")
    tap=$(get_tap_from_full_name "$full_name")
    if [[ -n "$tap" ]] && ! grep -qx "$tap" "$tmpdir/tracked_taps"; then
        new_taps+=("$tap")
    fi

    brew_name="$pkg"
    if [[ "$full_name" == */* ]]; then
        brew_name="$full_name"
    fi
    new_brews+=("$brew_name")
done < "$tmpdir/untracked_formulae"

while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    new_casks+=("$pkg")
done < "$tmpdir/untracked_casks"

while IFS= read -r app_id; do
    [[ -z "$app_id" ]] && continue
    app_name=$(mas list 2>/dev/null | awk -v id="$app_id" '$1 == id {
        $1 = ""; $NF = "";
        gsub(/^[[:space:]]+|[[:space:]]+$/, "");
        print; exit
    }')
    [[ -z "$app_name" ]] && continue
    new_mas+=("$app_name|$app_id")
done < "$tmpdir/untracked_mas"

# Deduplicate taps
readarray -t new_taps < <(printf '%s\n' "${new_taps[@]}" | sort -u)

total=$(( ${#new_brews[@]} + ${#new_casks[@]} + ${#new_mas[@]} ))

if [[ $total -eq 0 ]]; then
    echo -e "${GREEN}All packages are tracked! Nothing to sync.${NC}"
    exit 0
fi

# === Display preview ===
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                     BREW SYNC - UNTRACKED PACKAGES${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ ${#new_taps[@]} -gt 0 ]]; then
    echo -e "${CYAN}${BOLD}TAPS (${#new_taps[@]}):${NC}"
    for tap in "${new_taps[@]}"; do
        echo -e "  ${CYAN}$tap${NC}"
    done
    echo ""
fi

if [[ ${#new_brews[@]} -gt 0 ]]; then
    echo -e "${BLUE}${BOLD}BREWS (${#new_brews[@]}):${NC}"
    for brew in "${new_brews[@]}"; do
        desc=$(get_description "${brew##*/}")
        echo -e "  ${GREEN}$brew${NC}"
        [[ -n "$desc" ]] && echo -e "    ${DIM}$desc${NC}"
    done
    echo ""
fi

if [[ ${#new_casks[@]} -gt 0 ]]; then
    echo -e "${BLUE}${BOLD}CASKS (${#new_casks[@]}):${NC}"
    for cask in "${new_casks[@]}"; do
        desc=$(get_description "$cask")
        echo -e "  ${GREEN}$cask${NC}"
        [[ -n "$desc" ]] && echo -e "    ${DIM}$desc${NC}"
    done
    echo ""
fi

if [[ ${#new_mas[@]} -gt 0 ]]; then
    echo -e "${BLUE}${BOLD}MAS APPS (${#new_mas[@]}):${NC}"
    for entry in "${new_mas[@]}"; do
        IFS='|' read -r name id <<< "$entry"
        echo -e "  ${GREEN}$name${NC} ${DIM}(id: $id)${NC}"
    done
    echo ""
fi

echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}Total:${NC} $total packages (${#new_brews[@]} brews, ${#new_casks[@]} casks, ${#new_mas[@]} mas)"
if [[ $dep_count -gt 0 ]]; then
    echo -e "  ${DIM}($dep_count dependencies hidden - use --deps to include)${NC}"
fi
echo -e "  ${DIM}Target: $PACKAGES_YAML${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if $PREVIEW_ONLY; then
    echo -e "${DIM}Preview only mode. No changes made.${NC}"
    exit 0
fi

if ! $AUTO_APPLY; then
    echo -en "${BOLD}Apply these changes?${NC} [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${DIM}Applying changes to packages.yaml...${NC}"

python3 -c "
import yaml, sys

with open('$PACKAGES_YAML') as f:
    data = yaml.safe_load(f)

darwin = data.setdefault('darwin', {})
taps = darwin.setdefault('taps', [])
brews = darwin.setdefault('brews', [])
casks = darwin.setdefault('casks', [])
mas_apps = darwin.setdefault('mas', [])

new_taps = '''${new_taps[*]:-}'''.split()
new_brews = '''${new_brews[*]:-}'''.split()
new_casks = '''${new_casks[*]:-}'''.split()

for t in new_taps:
    if t and t not in taps:
        taps.append(t)

for b in new_brews:
    if b and b not in brews:
        brews.append(b)

for c in new_casks:
    if c and c not in casks:
        casks.append(c)

mas_entries = '''$(printf '%s\n' "${new_mas[@]:-}")'''.strip().splitlines()
existing_ids = {m['id'] for m in mas_apps}
for entry in mas_entries:
    if '|' not in entry:
        continue
    name, app_id = entry.rsplit('|', 1)
    app_id = int(app_id.strip())
    if app_id not in existing_ids:
        mas_apps.append({'name': name.strip(), 'id': app_id})

class FlowStyleDumper(yaml.SafeDumper):
    pass

def represent_mas(dumper, data):
    if isinstance(data, dict) and 'name' in data and 'id' in data:
        return dumper.represent_mapping('tag:yaml.org,2002:map', data.items(), flow_style=True)
    return dumper.represent_dict(data)

FlowStyleDumper.add_representer(dict, represent_mas)

with open('$PACKAGES_YAML', 'w') as f:
    yaml.dump(data, f, Dumper=FlowStyleDumper, default_flow_style=False, sort_keys=False)
"

echo -e "${GREEN}${BOLD}Done!${NC} Added $total packages to packages.yaml."
echo -e "${DIM}Run 'chezmoi apply' to install new packages.${NC}"
