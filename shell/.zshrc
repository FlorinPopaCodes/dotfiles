# Zinit plugin manager
source $HOMEBREW_PREFIX/opt/zinit/zinit.zsh

# Oh-my-zsh plugins (as snippets)
zinit snippet OMZP::bundler
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::common-aliases
zinit snippet OMZP::fzf
zinit snippet OMZP::gem
zinit snippet OMZP::git
zinit snippet OMZP::kube-ps1
zinit snippet OMZP::kubectl
zinit snippet OMZP::yarn

# External plugins
zinit light romkatv/zsh-defer

# Completions (with blockf to prevent conflicts)
zinit ice blockf
zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit

# Syntax highlighting MUST be loaded last
zinit light zsh-users/zsh-syntax-highlighting

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
