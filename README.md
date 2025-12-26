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

## Local Overrides

Machine-specific configs are supported via `.local` files (not tracked by git):

```bash
# Git: different email for work
cp git/.gitconfig.local.example ~/.gitconfig.local
# Edit ~/.gitconfig.local with work settings

# Shell: machine-specific paths, aliases
cp shell/.zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local with local settings
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

## TODO

- [ ] Arch Linux package lists
- [ ] neovim config

## Thanks

- [Dreams of Autonomy](https://github.com/dreamsofautonomy/dotfiles) - Stow setup inspiration
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) - macOS defaults approach
