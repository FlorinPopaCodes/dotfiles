# Personal dotfiles.

The plan is to update the current dotfile so I can more easily sync them across multiple machines using stow. Then move them to nix or something similar, so I can have a more declarative way of managing my dotfiles.

Optionally, check if I can use https://www.cachix.org/ to push changes to each env automagically.

# TODO

- [x] stow
- [x] ~/.config/kitty
- [ ] gitleaks for security
- [ ] git project config sync
- [ ] git signing key sync
- [ ] ssh 1password sync
- [ ] works on both mac and archlinux
- [ ] nix or something similar

# Install

```zsh
  brew install git stow
  git clone git@github.com:FlorinPopaCodes/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles
  stow .
  ???
```

### Stow Usage

Overwrite files from ~/ to ~/.dotfiles with:

```zsh
  stow --adopt .
```

Testing the stow command:

```zsh
  stow --verbose --simulate --adopt .
```

# Thanks

- Dreams of Autonomy
  - dotfiles https://github.com/dreamsofautonomy/dotfiles/tree/main
  - stow video https://youtu.be/y6XCebnB9gs?si=c68Ym91q6mN2brv3
  - zsh config video https://www.youtube.com/watch?v=ud7YxC33Z3w

# Quick Reference

- [Stow Ignore Lists](https://www.gnu.org/software/stow/manual/stow.html#Types-And-Syntax-Of-Ignore-Lists)
