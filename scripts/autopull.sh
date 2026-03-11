#!/bin/bash
# Auto-pull dotfiles and apply via chezmoi
# Sends macOS/Linux notification on failure

set -euo pipefail

SCRIPT_NAME="autopull"
LOG_FILE="${HOME}/.local/log/${SCRIPT_NAME}.log"
DOTFILES_DIR="${HOME}/.dotfiles"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify_failure() {
    local message="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        local escaped="${message//\"/\\\"}"
        osascript -e "display notification \"$escaped\" with title \"Cron Failed: $SCRIPT_NAME\" sound name \"Basso\""
    else
        notify-send "Cron Failed: $SCRIPT_NAME" "$message" 2>/dev/null || true
    fi
}

cd "$DOTFILES_DIR"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == gitbutler/* ]]; then
    log "On GitButler branch ($CURRENT_BRANCH), skipping auto-pull"
    exit 0
fi

log "Pulling and applying via chezmoi..."
if ! chezmoi update --force 2>&1 | tee -a "$LOG_FILE"; then
    log "FAILED: chezmoi update failed"
    notify_failure "chezmoi update failed - manual intervention needed"
    exit 1
fi

log "Completed successfully"
