# Dotfiles management with just
# Usage: just <recipe>

set dotenv-load
set shell := ["zsh", "-cu"]

home := env_var("HOME")
dotfiles := justfile_directory()

# Default: show available recipes
default:
    @just --list

# === STOW OPERATIONS ===

# Stow all core modules (shell, git)
stow: _ensure-stow
    @echo "Stowing core modules..."
    cd {{dotfiles}} && stow --verbose shell git
    @echo "Stowing terminal configs..."
    cd {{dotfiles}}/terminal && stow --verbose --target={{home}} kitty
    @echo "Done!"

# Unstow all modules
unstow:
    @echo "Unstowing all modules..."
    cd {{dotfiles}} && stow --verbose --delete shell git || true
    cd {{dotfiles}}/terminal && stow --verbose --delete --target={{home}} kitty || true
    @echo "Done!"

# Restow (unstow + stow) - useful after updates
restow: unstow stow

# Dry-run stow to check for conflicts
check:
    @echo "Checking for stow conflicts..."
    cd {{dotfiles}} && stow --verbose --simulate shell git
    cd {{dotfiles}}/terminal && stow --verbose --simulate --target={{home}} kitty

# Adopt existing files into dotfiles (overwrites dotfiles with existing)
adopt:
    @echo "Adopting existing files..."
    cd {{dotfiles}} && stow --verbose --adopt shell git
    cd {{dotfiles}}/terminal && stow --verbose --adopt --target={{home}} kitty

# === BREW OPERATIONS (macOS only) ===

# Install core CLI tools
brew-core: _ensure-macos _ensure-brew
    @echo "Installing core packages..."
    brew bundle --file={{dotfiles}}/macos/Brewfile.core

# Install GUI apps
brew-apps: _ensure-macos _ensure-brew
    @echo "Installing GUI apps..."
    brew bundle --file={{dotfiles}}/macos/Brewfile.apps

# Install dev tools
brew-dev: _ensure-macos _ensure-brew
    @echo "Installing dev tools..."
    brew bundle --file={{dotfiles}}/macos/Brewfile.dev

# Install all brew packages
brew-all: brew-core brew-apps brew-dev

# Check what would be installed
brew-check: _ensure-macos _ensure-brew
    @echo "=== Core packages ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.core || true
    @echo "\n=== GUI apps ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.apps || true
    @echo "\n=== Dev tools ==="
    brew bundle check --file={{dotfiles}}/macos/Brewfile.dev || true

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

# === INFO ===

# Show current stow status
status:
    @echo "=== Symlink Status ==="
    @ls -la {{home}}/.zshrc {{home}}/.gitconfig {{home}}/.config/kitty/kitty.conf 2>/dev/null || echo "Some links missing"
    @echo "\n=== Git Status ==="
    @cd {{dotfiles}} && git status --short

# Show OS info
info:
    @echo "OS: $(uname -s)"
    @echo "Dotfiles: {{dotfiles}}"
    @echo "Home: {{home}}"
    @command -v stow >/dev/null && echo "stow: $(which stow)" || echo "stow: not installed"
    @command -v brew >/dev/null && echo "brew: $(which brew)" || echo "brew: not installed"
    @command -v just >/dev/null && echo "just: $(which just)" || echo "just: not installed"
