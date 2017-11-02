source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    archlinux
    bundler
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
    globalias
    mafredri/zsh-async
    rupa/z
    sindresorhus/pure
    systemd
    zsh-users/zsh-completions
EOBUNDLES

antigen apply

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(direnv hook zsh)"
