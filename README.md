# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and automated with [just](https://github.com/casey/just).

## Structure

```
~/.dotfiles/
├── shell/          # zsh, zinit configs
├── git/            # gitconfig, gitignore
├── ssh/            # SSH config with 1Password agent
├── starship/       # Starship prompt config
├── terminal/
│   └── ghostty/    # Ghostty terminal config
├── macos/          # macOS-specific
│   ├── Brewfile.core   # Essential CLI tools
│   ├── Brewfile.apps   # GUI applications
│   ├── Brewfile.dev    # Development tools
│   └── .macos          # macOS system defaults
├── claude/         # Claude Code settings + commands
├── cron/           # LaunchAgents + scheduled scripts
├── arch/           # Arch Linux packages (TODO)
├── scripts/        # Custom scripts
└── justfile        # Automation recipes
```

## Quick Start

```bash
# Clone
git clone git@github.com:FlorinPopaCodes/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap (installs stow, just, core packages and symlinks)
just bootstrap

# Or manually:
brew install stow just
just stow
```

## Usage

```bash
just              # Show all available recipes
just stow         # Symlink all configs
just unstow       # Remove symlinks
just restow       # Unstow + stow (after updates)
just check        # Dry-run, check for conflicts

# macOS package management
just brew-core    # Install essential CLI tools
just brew-apps    # Install GUI applications
just brew-dev     # Install development tools
just brew-all     # Install everything

# macOS system defaults
just macos-defaults  # Apply developer-focused macOS settings

# Info
just status       # Show symlink and git status
just info         # Show environment info
```

## Modules

| Module | Description |
|--------|-------------|
| `shell` | zsh config, zinit plugins, aliases |
| `git` | git config with delta, commit signing via 1Password SSH |
| `ssh` | SSH config with 1Password SSH agent |
| `starship` | Custom prompt with git status and time |
| `terminal/ghostty` | Ghostty terminal config with Solarized Light theme |
| `claude` | Claude Code settings, commands, and statusline |
| `cron` | LaunchAgents and scheduled scripts |

## Local Overrides

Machine-specific configs are supported via `.local` files (not tracked by git):

| File | Purpose |
|------|---------|
| `~/.gitconfig.local` | Work email, different signing keys |
| `~/.zshrc.local` | Machine-specific paths, aliases |
| `~/.claude/settings.local.json` | Machine-specific Claude plugins/hooks |

```bash
# Git: different email for work
cp git/.gitconfig.local.example ~/.gitconfig.local

# Shell: machine-specific paths, aliases
cp shell/.zshrc.local.example ~/.zshrc.local

# Claude: machine-specific settings
cp claude/.claude/settings.local.json.example ~/.claude/settings.local.json
```

## Cross-Platform

- **macOS**: Full support with Brewfiles
- **Arch Linux**: TODO - `arch/packages.txt` and `arch/aur.txt`

## Brewfile Categories

| File | Contents |
|------|----------|
| `Brewfile.core` | stow, just, neovim, starship, fzf, ripgrep, zoxide, git-delta |
| `Brewfile.apps` | 1Password, Arc, Obsidian, Raycast, Ghostty |
| `Brewfile.dev` | node, rust, ruby, docker, various CLI tools |

Use `just brew-sync` to add untracked packages to the appropriate Brewfile.

## Cron Jobs (macOS)

Scheduled tasks use LaunchAgents with scripts in `cron/`:

```bash
just cron-install   # Install all launchd jobs
just cron-status    # Show loaded/unloaded status
just cron-test job  # Run a script manually
just cron-logs job  # View logs for a job
```

Logs are stored in `~/.local/log/<job-name>.log`.

## Key Shell Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `rm` | `gtrash put --rm-mode` | Safe delete to XDG trash |
| `c` | `claude` | Claude Code CLI |
| `j` / `cd` | `zoxide` | Smart directory jumping |
| `f` | `thefuck` | Fix last command |
| `ghc <url>` | - | Clone GitHub repo to `~/Developer/owner/repo` |

## Git Features

- **Global hooks** at `~/.git-hooks/` (passthrough to project hooks)
- **gitleaks** runs on pre-commit to block secrets
- **gitbutler/** branches blocked from push
- **GPG signing** via 1Password SSH
- **delta** for diffs, **mergiraf** for merge conflicts

## TODO

- [ ] Arch Linux package lists
- [ ] neovim config

## Thanks

- [Dreams of Autonomy](https://github.com/dreamsofautonomy/dotfiles) - Stow setup inspiration
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) - macOS defaults approach
