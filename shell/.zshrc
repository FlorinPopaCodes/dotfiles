source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
antigen init $HOME/.antigenrc

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(rbenv init - zsh)" # Slow
eval "$(fzf --zsh)"
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
eval $(thefuck --alias f)

alias rm="trash"

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
 
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

# DuckDB CLI
[[ -d "$HOME/.duckdb/cli/latest" ]] && export PATH="$HOME/.duckdb/cli/latest:$PATH"

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
# Try.rb (local script for managing try directories)
[[ -f ~/.local/try.rb ]] && eval "$(ruby ~/.local/try.rb init ~/Developer/tries)"

# Local overrides (not tracked by git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
