# True if $1 contains $2 as a substring.
__string_contains() {
    # If removing $2 from $1 makes a change, $1 contains $2.
    test "${1#*$2*}" != "$1"
}

pathcontains() {
    __string_contains ":$PATH:" ":$1:"
}

pathappend() {
    pathcontains "$1" || PATH="$PATH:$1"
}

pathprepend() {
    pathcontains "$1" || PATH="$1:$PATH"
}

# Ruby support.
rvmactivate() {
    if [ -d "$HOME/.rvm" ]; then
        if ! pathcontains "$HOME/.rvm/bin"; then
            pathprepend "$HOME/.rvm/bin"

            # Load RVM into a shell session *as a function* for interactive
            # shells.
            if [ -s "$HOME/.rvm/scripts/rvm" ]; then
                . "$HOME/.rvm/scripts/rvm"
            fi
        fi
    else
        echo "Missing ~/.rvm; can't activate"
        return 1
    fi
}

# pyenv support.
pyenvactivate() {
    if [ -d "$HOME/.pyenv" ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        if ! pathcontains "$PYENV_ROOT/bin"; then
            pathprepend "$PYENV_ROOT/bin"
            eval "$(pyenv init --path)"
            eval "$(pyenv init -)"
        fi
    else
        echo "Missing ~/.pyenv; can't activate"
        return 1
    fi
}
