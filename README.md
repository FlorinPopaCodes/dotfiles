# Personal dotfiles.

The plan is to update the current dotfile so I can more easily sync them across multiple machines using stow. Then move them to nix or something similar, so I can have a more declarative way of managing my dotfiles.

Optionally, check if I can use https://www.cachix.org/ to push changes to each env automagically.

# Install

```zsh
  brew install git stow
  git clone git@github.com:FlorinPopaCodes/dotfiles.git ~/.dotfiles
  ???
```

### Stow Usage

```zsh
  stow -t ~ <folder>
```
