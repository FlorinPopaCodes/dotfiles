## Development Workflow
- Never use the git commit command after a task is finished, use `but` or `but status` to see commit references.
- Run `just diff` to preview changes before applying
- Run `just apply` to apply dotfiles
- Run `just status` to verify managed files and git state

## Chezmoi Structure
- Source dir: `~/.dotfiles/` (set via `sourceDir` in `.chezmoi.yaml.tmpl`)
- `dot_` prefix → `.` in home (e.g., `dot_zshrc.tmpl` → `~/.zshrc`)
- `private_` prefix → 0600 permissions (e.g., `private_dot_ssh/`)
- `executable_` prefix → 0755 permissions
- `.tmpl` suffix → Go template with OS/machine conditionals
- `.chezmoidata/` → YAML data files (packages, machines)
- `.chezmoiscripts/` → `run_onchange_` scripts triggered by content hash changes
- `.chezmoiignore` → OS-conditional file exclusions
- `claude/` dir is NOT managed by chezmoi (ignored in `.chezmoiignore`)

## Key Aliases
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

## Packages
- `.chezmoidata/packages.yaml` — declarative package lists (darwin + linux)
- `run_onchange_darwin-packages.sh.tmpl` — auto-runs `brew bundle` when packages.yaml changes
- `run_onchange_linux-packages.sh.tmpl` — auto-runs `pacman`/`paru` when packages.yaml changes
- `just brew-sync` — sync untracked brew packages into packages.yaml
