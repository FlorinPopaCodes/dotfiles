# === ZINIT SETUP ===
source $HOMEBREW_PREFIX/opt/zinit/zinit.zsh

# === OH-MY-ZSH SNIPPETS (turbo mode) ===
zinit wait lucid for \
    OMZP::brew \
    OMZP::bundler \
    OMZP::colored-man-pages \
    OMZP::command-not-found \
    OMZP::common-aliases \
    OMZP::copyfile \
    OMZP::copypath \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::extract \
    OMZP::fzf \
    OMZP::gem \
    OMZP::git \
    OMZP::gitignore \
    OMZP::golang \
    OMZP::jsontools \
    OMZP::rust \
    OMZP::safe-paste \
    OMZP::sudo \
    OMZP::universalarchive

# Kubernetes (defer 1 second - not always needed immediately)
zinit wait"1" lucid for \
    OMZP::kube-ps1 \
    OMZP::kubectl

# === COMPLETIONS (turbo mode) ===
zinit wait lucid for \
    blockf \
    atload"zicompinit; zicdreplay" \
  zsh-users/zsh-completions

# === SYNTAX HIGHLIGHTING (must load after completions) ===
zinit wait"0b" lucid for \
  zsh-users/zsh-syntax-highlighting

# === IMMEDIATE TOOLS (must run before prompt) ===
eval "$(starship init zsh)"

# === DEFERRED TOOLS (turbo mode - run after prompt) ===
zinit wait lucid for \
    atload'eval "$(direnv hook zsh)"' \
  zdharma-continuum/null

zinit wait lucid for \
    atload'eval "$(rbenv init - zsh)"' \
  zdharma-continuum/null

zinit wait lucid for \
    atload'eval "$(fzf --zsh)"' \
  zdharma-continuum/null

zinit wait lucid for \
    atload'eval $(thefuck --alias f)' \
  zdharma-continuum/null

zinit wait lucid for \
    atload'eval "$(zoxide init zsh --cmd j)"' \
  zdharma-continuum/null

# === CONDITIONAL DEFERRED TOOLS ===
if command -v pnpm &>/dev/null; then
    zinit wait lucid for atload'eval "$(pnpm completion zsh)"' zdharma-continuum/null
fi

if command -v ngrok &>/dev/null; then
    zinit wait lucid for atload'eval "$(ngrok completion)"' zdharma-continuum/null
fi

if command -v gcloud &>/dev/null; then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# === ALIASES ===
alias rm="trash"

# === ENVIRONMENT ===
export EDITOR="nvim"
export HOMEBREW_NO_AUTO_UPDATE=1

# === GPG/SSH AGENT ===
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

# === CONDITIONAL PATHS ===
[[ -d "$HOME/.duckdb/cli/latest" ]] && export PATH="$HOME/.duckdb/cli/latest:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -f ~/.local/try.rb ]] && eval "$(ruby ~/.local/try.rb init ~/Developer/tries)"

# === LOCAL OVERRIDES ===
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
