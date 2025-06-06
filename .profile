export PROFILE_SOURCED=YES

. "$HOME/.common.sh"

umask 002

# In case `~/.ssh` got created with bad permissions via `homegit`, check and
# correct the permissions at login.
test -d ~/.ssh && find ~/.ssh -prune \( \
  -perm -g=r -o \
  -perm -g=w -o \
  -perm -g=x -o \
  -perm -o=r -o \
  -perm -o=w -o \
  -perm -o=x \) -exec chmod 700 {} +

# Append to PATH (so that network search is done last).
pathappend "$HOME/x/bin"

# Prepend to PATH (so that local binaries win).

# On CentOS, root lacks /usr/local/bin for "security" reasons.
pathprepend '/usr/local/bin'

pathprepend "$HOME/bin"
pathprepend "$HOME/bin2"
pathprepend "$HOME/.local/bin"

# Go support.
if [ -d "$HOME/go" ]; then
    export GOPATH=$HOME/go
    pathprepend "$GOPATH/bin"
fi

# Rust support.
pathprepend "$HOME/.cargo/bin"

# virtualenv support.
export WORKON_HOME=$HOME/envs

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
