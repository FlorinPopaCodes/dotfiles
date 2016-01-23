source /usr/share/zsh/scripts/antigen/antigen.zsh

setopt HIST_IGNORE_ALL_DUPS

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    archlinux
    common-aliases
    docker
    extract
    gem
    git
    mafredri/zsh-async
    systemd
    sindresorhus/pure
    vim-interaction
    zsh-users/zsh-completions src
    zsh-users/zsh-history-substring-search
    zsh-users/zsh-syntax-highlighting
EOBUNDLES

antigen apply

# misc
export EDITOR=gvim
export SHELL=zsh

# chruby
source /usr/share/chruby/chruby.sh
source /usr/share/chruby/auto.sh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# envoy
envoy
source <(envoy -p)

# direnv
eval "$(direnv hook zsh)"
