# Dotfiles management with just
# Usage: just <recipe>

set dotenv-load
set shell := ["bash", "-cu"]

home := env_var("HOME")
dotfiles := justfile_directory()

# Default: show available recipes
default:
    @just --list

# === STOW OPERATIONS ===

# Stow all core modules (shell, git, starship, claude)
stow: _ensure-stow
    @echo "Stowing core modules..."
    cd {{dotfiles}} && stow --verbose shell git starship claude
    @echo "Stowing terminal configs..."
    cd {{dotfiles}}/terminal && stow --verbose --target={{home}} ghostty
    @echo "Done!"

# Unstow all modules
unstow:
    @echo "Unstowing all modules..."
    cd {{dotfiles}} && stow --verbose --delete shell git starship claude || true
    cd {{dotfiles}}/terminal && stow --verbose --delete --target={{home}} ghostty || true
    @echo "Done!"

# Restow (unstow + stow) - useful after updates
restow: unstow stow

# Dry-run stow to check for conflicts
check:
    @echo "Checking for stow conflicts..."
    cd {{dotfiles}} && stow --verbose --simulate shell git starship claude
    cd {{dotfiles}}/terminal && stow --verbose --simulate --target={{home}} ghostty

# Adopt existing files into dotfiles (overwrites dotfiles with existing)
adopt:
    @echo "Adopting existing files..."
    cd {{dotfiles}} && stow --verbose --adopt shell git starship claude
    cd {{dotfiles}}/terminal && stow --verbose --adopt --target={{home}} ghostty

# === BREW OPERATIONS (macOS only) ===

# Install core CLI tools
brew-core: _ensure-macos _ensure-brew
    @echo "Installing core packages..."
    brew bundle install --file={{dotfiles}}/macos/Brewfile.core

# Install GUI apps
brew-apps: _ensure-macos _ensure-brew
    @echo "Installing GUI apps..."
    brew bundle install --file={{dotfiles}}/macos/Brewfile.apps

# Install dev tools
brew-dev: _ensure-macos _ensure-brew
    @echo "Installing dev tools..."
    brew bundle install --file={{dotfiles}}/macos/Brewfile.dev

# Install VS Code extensions
brew-vscode: _ensure-macos _ensure-brew
    @echo "Installing VS Code extensions..."
    brew bundle install --file={{dotfiles}}/macos/Brewfile.vscode

# Install all brew packages
brew-all: brew-core brew-apps brew-dev brew-vscode

# Check what would be installed (shows all, fails if any missing)
brew-check: _ensure-macos _ensure-brew
    #!/usr/bin/env bash
    set -u
    failed=0
    echo "=== Core packages ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.core || failed=1
    echo ""
    echo "=== GUI apps ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.apps || failed=1
    echo ""
    echo "=== Dev tools ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.dev || failed=1
    echo ""
    echo "=== VS Code extensions ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.vscode || failed=1
    exit $failed

# Dump current brew packages to Brewfiles
brew-dump: _ensure-macos _ensure-brew
    @echo "Dumping brew packages (backup before running)..."
    brew bundle dump --force --file={{dotfiles}}/macos/Brewfile.dump
    @echo "Dumped to macos/Brewfile.dump"

# === MACOS DEFAULTS ===

# Apply macOS system defaults (creates .macos if missing)
macos-defaults: _ensure-macos
    @echo "Applying macOS defaults..."
    @if [ -f {{dotfiles}}/macos/.macos ]; then \
        bash {{dotfiles}}/macos/.macos; \
    else \
        echo "No .macos script found. Create one at macos/.macos"; \
    fi

# === ARCH LINUX OPERATIONS ===

# Install packages on Arch Linux
arch-install: _ensure-arch
    @echo "Installing Arch packages..."
    @if [ -f {{dotfiles}}/arch/packages.txt ]; then \
        sudo pacman -S --needed $(cat {{dotfiles}}/arch/packages.txt); \
    else \
        echo "No packages.txt found"; \
    fi
    @if [ -f {{dotfiles}}/arch/aur.txt ]; then \
        paru -S --needed $(cat {{dotfiles}}/arch/aur.txt); \
    else \
        echo "No aur.txt found"; \
    fi

# === BOOTSTRAP ===

# Full bootstrap: install deps + stow
bootstrap:
    @echo "Bootstrapping dotfiles..."
    @if [ "$(uname)" = "Darwin" ]; then \
        just brew-core && just stow; \
    elif [ -f /etc/arch-release ]; then \
        just arch-install && just stow; \
    else \
        echo "Unknown OS. Installing stow manually..."; \
        just stow; \
    fi
    @echo "Bootstrap complete!"

# === HELPER RECIPES ===

# Ensure stow is installed
_ensure-stow:
    @command -v stow >/dev/null || (echo "stow not found. Installing..." && brew install stow)

# Ensure brew is installed
_ensure-brew:
    @command -v brew >/dev/null || (echo "brew not found. Install from https://brew.sh" && exit 1)

# Ensure running on macOS
_ensure-macos:
    @[ "$(uname)" = "Darwin" ] || (echo "This recipe is macOS only" && exit 1)

# Ensure running on Arch Linux
_ensure-arch:
    @[ -f /etc/arch-release ] || (echo "This recipe is Arch Linux only" && exit 1)

# === CRON/LAUNCHD OPERATIONS (macOS) ===

# Install all launchd jobs
cron-install: _ensure-macos
    @echo "Installing launchd jobs..."
    @for plist in {{dotfiles}}/cron/launchd/Library/LaunchAgents/*.plist; do \
        name=$(basename "$plist"); \
        cp "$plist" ~/Library/LaunchAgents/; \
        launchctl unload ~/Library/LaunchAgents/"$name" 2>/dev/null || true; \
        launchctl load ~/Library/LaunchAgents/"$name"; \
        echo "Installed: $name"; \
    done
    @echo "Done! Use 'just cron-status' to verify."

# Uninstall all launchd jobs
cron-uninstall: _ensure-macos
    @echo "Uninstalling launchd jobs..."
    @for plist in {{dotfiles}}/cron/launchd/Library/LaunchAgents/*.plist; do \
        name=$(basename "$plist"); \
        launchctl unload ~/Library/LaunchAgents/"$name" 2>/dev/null || true; \
        rm -f ~/Library/LaunchAgents/"$name"; \
        echo "Removed: $name"; \
    done
    @echo "Done!"

# Show status of all cron jobs
cron-status: _ensure-macos
    @echo "=== Installed LaunchAgents ==="
    @for plist in {{dotfiles}}/cron/launchd/Library/LaunchAgents/*.plist; do \
        name=$(basename "$plist" .plist); \
        if launchctl list | grep -q "$name"; then \
            echo "✓ $name (loaded)"; \
        else \
            echo "✗ $name (not loaded)"; \
        fi; \
    done

# Show cron job logs
cron-logs job="gtrash-prune":
    @echo "=== Application Log ==="
    @tail -20 ~/.local/log/{{job}}.log 2>/dev/null || echo "No log file yet"
    @echo ""
    @echo "=== launchd stdout ==="
    @tail -10 /tmp/com.florinpopa.{{job}}.stdout.log 2>/dev/null || echo "No stdout log"
    @echo ""
    @echo "=== launchd stderr ==="
    @tail -10 /tmp/com.florinpopa.{{job}}.stderr.log 2>/dev/null || echo "No stderr log"

# Run a cron script manually for testing
cron-test job="gtrash-prune":
    @echo "Running {{job}} manually..."
    {{dotfiles}}/cron/scripts/{{job}}.sh

# === INFO ===

# Show current stow status
status:
    @echo "=== Symlink Status ==="
    @ls -la {{home}}/.zshrc {{home}}/.gitconfig {{home}}/.config/starship.toml {{home}}/.config/ghostty {{home}}/.claude/settings.json 2>/dev/null || echo "Some links missing"
    @echo ""
    @echo "=== Git Status ==="
    @cd {{dotfiles}} && git status --short

# Show OS info
info:
    @echo "OS: $(uname -s)"
    @echo "Dotfiles: {{dotfiles}}"
    @echo "Home: {{home}}"
    @command -v stow >/dev/null && echo "stow: $(which stow)" || echo "stow: not installed"
    @command -v brew >/dev/null && echo "brew: $(which brew)" || echo "brew: not installed"
    @command -v just >/dev/null && echo "just: $(which just)" || echo "just: not installed"
