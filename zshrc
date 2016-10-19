source /usr/share/zsh/scripts/antigen/antigen.zsh

setopt HIST_IGNORE_ALL_DUPS

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    archlinux
    colored-man-pages
    command-not-found
    common-aliases
    docker
    emacs
    extract
    fasd
    gem
    git
    git-flow-avh
    mafredri/zsh-async
    rupa/z
    sindresorhus/pure
    systemd
    tmux
    vim-interaction
    zsh-users/zsh-completions
EOBUNDLES

antigen apply


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
