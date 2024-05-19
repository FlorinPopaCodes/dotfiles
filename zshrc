source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
antigen init $HOME/.antigenrc

eval "$(starship init zsh)"
zsh-defer eval "$(direnv hook zsh)"
zsh-defer eval "$(rbenv init - zsh)" # Slow
zsh-defer eval "$(gh copilot alias -- zsh)" # Can be improved
if command -v ngrok &>/dev/null; then
  zsh-defer eval "$(ngrok completion)"
fi
zsh-defer eval $(thefuck --alias f)

alias rm="trash"

export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export EDITOR="nvim"
export HOMEBREW_NO_AUTO_UPDATE=1


# fpath=(~/.stripe $fpath)

# Slow
# if type brew &>/dev/null; then
#     FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
#     autoload -Uz compinit
#     compinit
# fi
