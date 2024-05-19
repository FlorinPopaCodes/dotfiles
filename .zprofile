eval "$(/opt/homebrew/bin/brew shellenv)"

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent


# Added by Toolbox App
export PATH="$PATH:/Users/florinpopa/Library/Application Support/JetBrains/Toolbox/scripts:/Applications/RubyMine.app/Contents/MacOS"

export PATH=$PATH:$(go env GOPATH)/bin

