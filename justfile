set shell := ["bash", "-cu"]
dotfiles := justfile_directory()

# Default: show available recipes
default:
    @just --list

# === CHEZMOI OPERATIONS ===

# Apply all dotfiles
apply:
    chezmoi apply -v

# Show what would change
diff:
    chezmoi diff

# Pull remote changes and apply
update:
    chezmoi update -v

# Re-init config (after changing .chezmoi.yaml.tmpl)
init:
    chezmoi init --source {{ dotfiles }}

# Edit a managed file (opens source, applies on save)
edit file:
    chezmoi edit {{ file }}

# === MACOS DEFAULTS ===

# Apply macOS system defaults
macos-defaults: _ensure-macos
    @echo "Applying macOS defaults..."
    @if [ -f {{ dotfiles }}/scripts/macos-defaults.sh ]; then \
        bash {{ dotfiles }}/scripts/macos-defaults.sh; \
    else \
        echo "No macos-defaults.sh found"; \
    fi

# === STATUS ===

# Show dotfiles status
status:
    @echo "=== Managed Files ==="
    @chezmoi status
    @echo ""
    @echo "=== Git Status ==="
    @cd {{ dotfiles }} && git status --short

# Show what chezmoi manages
managed:
    chezmoi managed

# === BOOTSTRAP ===

# Bootstrap on a new machine
bootstrap:
    chezmoi init --apply FlorinPopaCodes/dotfiles

# === HELPERS ===

_ensure-macos:
    @[ "$(uname)" = "Darwin" ] || (echo "This recipe is macOS only" && exit 1)
