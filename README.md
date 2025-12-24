# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and automated with [just](https://github.com/casey/just).

## Structure

```
~/.dotfiles/
├── shell/          # zsh, zinit configs
├── git/            # gitconfig, gitignore
├── starship/       # Starship prompt config
├── terminal/
│   ├── kitty/      # Kitty terminal config
│   └── ghostty/    # Ghostty terminal config
├── macos/          # macOS-specific
│   ├── Brewfile.core   # Essential CLI tools
│   ├── Brewfile.apps   # GUI applications
│   └── Brewfile.dev    # Development tools
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

# Info
just status       # Show symlink and git status
just info         # Show environment info
```

## Modules

| Module | Description |
|--------|-------------|
| `shell` | zsh config, zinit plugins, aliases |
| `git` | git config with delta, GPG signing via 1Password |
| `starship` | Custom prompt with git status and time |
| `terminal/kitty` | Kitty config with Solarized Light theme |
| `terminal/ghostty` | Ghostty config matching kitty theme |

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
| `Brewfile.core` | stow, just, neovim, starship, fzf, ripgrep, git-delta |
| `Brewfile.apps` | 1Password, Arc, Slack, Obsidian, Raycast, Ghostty |
| `Brewfile.dev` | node, rust, ruby, docker, postgres, various CLI tools |

## TODO

- [ ] Arch Linux package lists
- [ ] macOS defaults script (`.macos`)
- [ ] neovim config
- [ ] Shell startup optimization (lazy loading)

## Thanks

- [Dreams of Autonomy](https://github.com/dreamsofautonomy/dotfiles) - Stow setup inspiration
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) - macOS defaults approach
