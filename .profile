if [ "$PROFILE_SOURCED" = "YES" ]; then
    return
fi

export PROFILE_SOURCED=YES

. "$HOME/.common.sh"

umask 002

# Append to PATH (so that network search is done last).
pathappend "$HOME/x/bin"

# Prepend to PATH (so that local binaries win).
pathprepend "$HOME/bin"
pathprepend "$HOME/bin2"
pathprepend "$HOME/.local/bin"

# Go support.
if [ -d "$HOME/go" ]; then
    export GOPATH=$HOME/go
    pathprepend "$GOPATH/bin"
fi

# Ruby support.
pathprepend "$HOME/.rvm/bin"

# Rust support.
pathprepend "$HOME/.cargo/bin"

# virtualenv support.
export WORKON_HOME=$HOME/envs
export PROJECT_HOME=$HOME/projects
VIRTUALENVWRAPPER_PYTHON=/usr/local/lib/pipx/venvs/virtualenvwrapper/bin/python
if [ -x "$VIRTUALENVWRAPPER_PYTHON" ]; then
    export VIRTUALENVWRAPPER_PYTHON
else
    unset VIRTUALENVWRAPPER_PYTHON
fi

# pyenv support.
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathprepend "$PYENV_ROOT/bin"
    eval "$(pyenv init -)"
fi

# Per-host PATH.
HOSTNAME="$(hostname)"
HOST="${HOSTNAME%%.*}"
HOST_BIN="$HOME/bin-$HOST"
if [ -d "$HOST_BIN" ]; then
    pathprepend "$HOST_BIN"
fi

# Support for Visual Studio on Windows.
if [ -n "$HOMEDRIVE" ]; then
    # This is windows.
    vs90="$VS90COMNTOOLS"
    if [ -n "$vs90" ]; then
        # Convert from Windows path to Cygwin path, then convert:
        # .../Microsoft Visual Studio 9.0/Common7/Tools
        # into:
        # .../Microsoft Visual Studio 9.0/VC/bin
        vs90=$(cygpath "$vs90")
        vs90=$(dirname "$vs90")
        vs90=$(dirname "$vs90")
        export VC9PATH="$vs90/VC/bin:$vs90/Common7/IDE"
    fi
    export MAKE_MODE=unix
fi

##############################################################################
# General environment variables

export EDITOR=vim
export VISUAL=vim
export LESS=-iR

# Make ``less`` more friendly for non-text input files, see lesspipe(1).
[ -z "$LESSOPEN" ] &&
    [ -x /usr/bin/lesspipe ] &&
    eval "$(SHELL=/bin/sh lesspipe)"


##############################################################################
# keychain support

# Require interactive shell, keychain present, and stdin/stdout are ttys.
if [ "$PS1" ] && [ "$(command -v keychain)" ] && tty -s && tty -s 0<&1; then
    eval "$(keychain --eval --nogui --quiet "$(~/bin/ssh-identities)")"
fi

##############################################################################
# Extra .profile2 support
if [ -f "$HOME/.profile2" ]; then
    . "$HOME/.profile2"
fi

##############################################################################
# Bash-specific interactive settings

if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
