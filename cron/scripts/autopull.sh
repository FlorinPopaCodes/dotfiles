#!/bin/bash
# Auto-pull dotfiles repository and restow
# Sends macOS notification on failure

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
    local escaped="${message//\"/\\\"}"
    osascript -e "display notification \"$escaped\" with title \"Cron Failed: $SCRIPT_NAME\" sound name \"Basso\""
}

cd "$DOTFILES_DIR"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == gitbutler/* ]]; then
    log "On GitButler branch ($CURRENT_BRANCH), skipping auto-pull"
    exit 0
fi

log "Fetching origin..."
git fetch origin 2>&1 | tee -a "$LOG_FILE"

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date"
    exit 0
fi

log "Updates available, pulling..."
if ! git pull --ff-only 2>&1 | tee -a "$LOG_FILE"; then
    log "FAILED: git pull failed (possible conflicts)"
    notify_failure "git pull failed - manual intervention needed"
    exit 1
fi

log "Running restow..."
if ! just restow 2>&1 | tee -a "$LOG_FILE"; then
    log "FAILED: just restow failed"
    notify_failure "just restow failed after pull"
    exit 1
fi

log "Completed successfully"
