if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Directories to append to PATH
typeset -a append_dirs=(
    ~/Library/Application\ Support/JetBrains/Toolbox/scripts
    /Applications/RubyMine.app/Contents/MacOS
    $(go env GOPATH)/bin
)

# Directories to prepend to PATH
typeset -a prepend_dirs=(
    ~/.rbenv/bin
    /opt/homebrew/opt/libpq/bin
)

# Appending directories
for dir in ${append_dirs[@]}; do
    if [[ -d $dir ]]; then
        path+=("$dir")
    fi
done

# Prepending directories (reversed to maintain order)
for dir in ${append_dirs[@]}; do
    if [[ -d $dir ]]; then
        path=("$dir" $path)
    fi
done

# Export the updated PATH
export PATH
