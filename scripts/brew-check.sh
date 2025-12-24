#!/usr/bin/env bash
# Check brew sync: shows missing from configs and missing from system
set -u

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Combine all Brewfiles to check what's installed but not tracked
combined=$(mktemp)
cat "$DOTFILES/macos/Brewfile.core" "$DOTFILES/macos/Brewfile.apps" "$DOTFILES/macos/Brewfile.dev" "$DOTFILES/macos/Brewfile.vscode" > "$combined"

# Get missing from configs (installed but not in ANY Brewfile)
# Filter to just package names, not headers or cleanup suggestions
missing_configs=$(brew bundle cleanup --file="$combined" 2>/dev/null | grep -v "^Would " | grep -v "^$" | grep -v "^=>" | grep -v "Would remove" | grep -v "^Run " | grep -v "operation would free" || true)
rm -f "$combined"

# Collect all missing from system
all_missing_system=""
for name in core apps dev vscode; do
    bf="$DOTFILES/macos/Brewfile.$name"
    [ -f "$bf" ] || continue
    result=$(brew bundle check --verbose --file="$bf" 2>&1 | grep "^→" | sed 's/^→ //' | sed 's/ needs to be.*//' || true)
    [ -n "$result" ] && all_missing_system+="$result"$'\n'
done
missing_system=$(echo "$all_missing_system" | grep -v "^$" | sort -u || true)

# Count
sys_count=0
cfg_count=0
[ -n "$missing_system" ] && sys_count=$(echo "$missing_system" | wc -l | tr -d ' ')
[ -n "$missing_configs" ] && cfg_count=$(echo "$missing_configs" | wc -l | tr -d ' ')

# Print header
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                              BREW SYNC STATUS                                ║"
echo "╠═══════════════════════════════════════╤══════════════════════════════════════╣"
echo "║  MISSING FROM CONFIGS (not tracked)   │  MISSING FROM SYSTEM (not installed) ║"
echo "╠═══════════════════════════════════════╪══════════════════════════════════════╣"

# Combine into two columns
if [ "$cfg_count" -eq 0 ] && [ "$sys_count" -eq 0 ]; then
    printf "║  %-37s │  %-36s ║\n" "✓ All tracked" "✓ All installed"
else
    paste <(echo "$missing_configs") <(echo "$missing_system") | while IFS=$'\t' read -r left right; do
        printf "║  %-37s │  %-36s ║\n" "${left:-}" "${right:-}"
    done
fi

echo "╠═══════════════════════════════════════╧══════════════════════════════════════╣"
printf "║  %-76s ║\n" "Total: $cfg_count not tracked, $sys_count not installed"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"

# Exit with error if anything is missing from system
[ "$sys_count" -eq 0 ] || exit 1
