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

# === BREW OPERATIONS (macOS only) ===

# Sync untracked brew packages into packages.yaml
brew-sync *args: _ensure-macos _ensure-brew
    @DOTFILES={{ dotfiles }} {{ dotfiles }}/scripts/brew-sync.sh {{ args }}

# === MACOS DEFAULTS ===

# Apply macOS system defaults
macos-defaults: _ensure-macos
    @echo "Applying macOS defaults..."
    @if [ -f {{ dotfiles }}/scripts/macos-defaults.sh ]; then \
        bash {{ dotfiles }}/scripts/macos-defaults.sh; \
    else \
        echo "No macos-defaults.sh found"; \
    fi

# === CRON/SCHEDULED TASKS ===

# Show cron job logs
cron-logs job="gtrash-prune":
    @echo "=== Application Log ==="
    @tail -20 ~/.local/log/{{ job }}.log 2>/dev/null || echo "No log file yet"
    @echo ""
    @echo "=== launchd stdout ==="
    @tail -10 /tmp/com.florinpopa.{{ job }}.stdout.log 2>/dev/null || echo "No stdout log"
    @echo ""
    @echo "=== launchd stderr ==="
    @tail -10 /tmp/com.florinpopa.{{ job }}.stderr.log 2>/dev/null || echo "No stderr log"

# Run a cron script manually for testing
cron-test job="gtrash-prune":
    @echo "Running {{ job }} manually..."
    {{ dotfiles }}/scripts/{{ job }}.sh

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

_ensure-brew:
    @command -v brew >/dev/null || (echo "brew not found. Install from https://brew.sh" && exit 1)

_ensure-macos:
    @[ "$(uname)" = "Darwin" ] || (echo "This recipe is macOS only" && exit 1)
