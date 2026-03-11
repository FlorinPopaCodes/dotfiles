#!/bin/bash
# Prune trash files older than 30 days
# Sends macOS notification on failure

set -euo pipefail

SCRIPT_NAME="gtrash-prune"
LOG_FILE="${HOME}/.local/log/${SCRIPT_NAME}.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify_failure() {
    local message="$1"
    # Escape double quotes for osascript
    local escaped="${message//\"/\\\"}"
    osascript -e "display notification \"$escaped\" with title \"Cron Failed: $SCRIPT_NAME\" sound name \"Basso\""
}

log "Starting gtrash prune..."

# Run command and capture exit code properly (pipefail is set)
gtrash prune --day 30 2>&1 | tee -a "$LOG_FILE"
exit_code=${PIPESTATUS[0]}

if [ $exit_code -eq 0 ]; then
    log "Completed successfully"
else
    log "FAILED with exit code $exit_code"
    notify_failure "gtrash prune failed. Check $LOG_FILE"
    exit 1
fi
