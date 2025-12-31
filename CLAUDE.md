## Development Workflow
- Never use the git commit command after a task is finished, use `but` or `but status` to see commit references.
- Run `just check` before stowing to detect conflicts
- Run `just restow` after modifying dotfiles structure
- Run `just status` to verify symlinks and git state

## Stow Structure
- **Nested stow**: `terminal/` uses `--target=$HOME` from subdirectory (different pattern)
- Module paths mirror `$HOME`: e.g., `claude/.claude/` → `~/.claude/`, `ssh/.ssh/` → `~/.ssh/`
- Files prefixed with `.` become dotfiles in `$HOME`

## Key Aliases
- `rm` → `gtrash put --rm-mode` (safe delete to XDG trash)
- `c` → `claude`
- `j` / `cd` → zoxide (smart cd)
- `f` → thefuck
- `ghc <github-url>` → clones to `~/Developer/owner/repo` and cds into it

## Git Behaviors
- Global hooks at `~/.git-hooks/` override per-project hooks but passthrough if project hooks exist
- `gitleaks` runs on pre-commit (blocks secrets)
- `gitbutler/*` branches blocked from push
- Commits GPG-signed via 1Password SSH (`op-ssh-sign`)
- Uses `delta` for diffs, `mergiraf` for merge conflicts

## Local Override Pattern
Machine-specific configs (not tracked):
- `~/.gitconfig.local` — included via git's `[include]`
- `~/.zshrc.local` — sourced at end of .zshrc
- `~/.claude/settings.local.json`

## Cron Jobs
- LaunchAgents: `cron/launchd/Library/LaunchAgents/`
- Scripts: `cron/scripts/<job-name>.sh`
- Logs: `~/.local/log/<job-name>.log`
- Commands: `just cron-install`, `just cron-status`, `just cron-test <job>`, `just cron-logs <job>`

## Brewfiles
- `Brewfile.core` — essential CLI tools
- `Brewfile.apps` — GUI apps  
- `Brewfile.dev` — dev tools
- `just brew-check` — show sync status between configs and system
