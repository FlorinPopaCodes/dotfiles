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
    gem
    git
    fzf
    asdf
    mafredri/zsh-async
    sindresorhus/pure
    systemd
    yarn
    zsh-users/zsh-completions
EOBUNDLES

antigen apply

eval "$(direnv hook zsh)"
