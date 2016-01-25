source /usr/share/zsh/scripts/antigen/antigen.zsh

setopt HIST_IGNORE_ALL_DUPS

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    archlinux
    common-aliases
    docker
    emacs
    extract
    fasd
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
export LEDGER_FILE=~/Documents/Ledgers/Personal.dat
export SHELL=zsh

export PATH=$PATH:~/.local/bin:~/bin

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
