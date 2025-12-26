#!/usr/bin/env bash
# Check brew sync: shows missing from configs and missing from system
set -u

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Run all checks in parallel
cat "$DOTFILES/macos/Brewfile.core" "$DOTFILES/macos/Brewfile.apps" "$DOTFILES/macos/Brewfile.dev" > "$tmpdir/combined"

# Start all brew commands in parallel
brew bundle cleanup --file="$tmpdir/combined" 2>/dev/null > "$tmpdir/cleanup" &
brew bundle check --verbose --file="$DOTFILES/macos/Brewfile.core" 2>&1 > "$tmpdir/core" &
brew bundle check --verbose --file="$DOTFILES/macos/Brewfile.apps" 2>&1 > "$tmpdir/apps" &
brew bundle check --verbose --file="$DOTFILES/macos/Brewfile.dev" 2>&1 > "$tmpdir/dev" &
wait

# Process results
missing_configs=$(cat "$tmpdir/cleanup" | grep -v "^Would " | grep -v "^$" | grep -v "^=>" | grep -v "Would remove" | grep -v "^Run " | grep -v "operation would free" || true)
missing_system=$(cat "$tmpdir/core" "$tmpdir/apps" "$tmpdir/dev" | grep "^→" | sed 's/^→ //' | sed 's/ needs to be.*//' | sort -u || true)

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
