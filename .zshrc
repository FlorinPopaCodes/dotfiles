source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
antigen init $HOME/.antigenrc

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(rbenv init - zsh)" # Slow
eval "$(fzf --zsh)"
# https://docs.github.com/en/copilot/github-copilot-in-the-cli/setting-up-github-copilot-in-the-cli
# Check if command exists before running it
eval "$(gh copilot alias -- zsh)" # Can be improved
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
eval $(thefuck --alias f)

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
if command -v gcloud &>/dev/null; then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi
