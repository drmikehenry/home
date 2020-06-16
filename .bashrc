# .bashrc

# Check for an interactive session.
[ -z "$PS1" ] && return

export BASHRC_SOURCED=YES

. "$HOME/.common.sh"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

HISTSIZE=300000

# Disable Bash's "command not found" hook that causes delays.
unset command_not_found_handle

# Disable XON/XOFF so CTRL-S and CTRL-Q are available to Vim and friends
# when connected to a terminal.
test -t 0 && stty -ixon -ixoff

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Allow "**" in globs; ignore failures, as sparc solaris 2.10 lacks this.
shopt -s globstar 2> /dev/null

# Allow extended glob syntax.  These include:
# ?(pattern-list) Matches zero or one occurrence of the given patterns.
# *(pattern-list) Matches zero or more occurrences of the given patterns.
# +(pattern-list) Matches one or more occurrences of the given patterns.
# @(pattern-list) Matches one of the given patterns.
# !(pattern-list) Matches anything except one of the given patterns.
shopt -s extglob

# Make ``less`` more friendly for non-text input files, see lesspipe(1).
[ -z "$LESSOPEN" -a -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below).
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='[${debian_chroot:+($debian_chroot)}\u@\h:\W]\$ '

# If this is an xterm set the title to user@host:dir.
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \W\a\]$PS1"
    ;;
*)
    ;;
esac

# User specific aliases and functions

# Use color only if that works.
if ls --color=auto &> /dev/null; then
    lsHasColor=true
    alias ls='ls --color=auto'
else
    lsHasColor=false
fi
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lArt'
if $lsHasColor; then
    alias lll='ls -lArt --color=yes | less -iR'
else
    alias lll='ls -lArt | less -i'
fi
alias root='ssh root@localhost'
alias qdig='dig +short +identify +search'
alias ttop='/usr/bin/top -ocpu -R -F -s 2 -n30'

ttar()
{
    tar -tf "$@" | less -iR
}
alias xtar='tar -xf'
alias xttar='xtar'

tzip()
{
    unzip -t "$@" | less -iR
}
alias xzip='unzip -q'
alias xtzip='xzip'

# Work around incorrect detection of stdin == tty on Windows using Git-Bash.
ptwrap()
{
    if test -t 0; then
        'pt' < /dev/null "$@"
    else
        'pt' "$@"
    fi
}
alias pt='ptwrap'

# Work around incorrect detection of stdin == tty on Windows using Git-Bash.
agwrap()
{
    if test -t 0; then
        'ag' < /dev/null "$@"
    else
        'ag' "$@"
    fi
}
alias ag='agwrap'

psl()
{
    TMPFILE="/tmp/tmp-psl-$USER.$$"
    ps -eFHww > "$TMPFILE"
    if [ -z "$1" ]; then
        less < "$TMPFILE"
    else
        grep --color=auto "$@" < "$TMPFILE"
    fi
    rm -f "$TMPFILE"
}

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias kdiff='kdiff3'
alias svn='svnwrap'
alias sdist='python setup.py -q sdist bdist_wheel'

# dnf-specific aliases.
# sudo is used for all of them so that caching always happens for root.
alias dnfi='sudo -H dnf -qy install'
alias dnfs='sudo -H dnf search'
alias dnfgi='sudo -H dnf -qy groupinstall'
alias dnflu='sudo -H dnf list updates'
alias dnfu='sudo -H dnf -y update'
alias dnflu='sudo -H dnf list updates'

# Yum-specific aliases.
# sudo is used for all of them so that caching always happens for root.
alias yi='sudo -H yum -y install'
alias ys='sudo -H yum search'
alias ygi='sudo -H yum -y groupinstall'
alias ylu='sudo -H yum list updates'
alias yu='sudo -H yum -y update'

# Apt-get-specific aliases.
alias agi='sudo -H apt-get -y install'
alias agu='sudo -H apt-get update'
alias agdu='sudo -H apt-get -y dist-upgrade'
alias acs='apt-cache search'
alias acshow='apt-cache show'
alias dpkg-stat='dpkg -s'

alias ipy='ipython'
alias py='python'

alias df='df -h -x tmpfs -x squashfs -x devtmpfs'

dush()
{
    if [ -z "$1" ]; then
        du --total -sh ./* | sort -h
    else
        du --total -sh "$@" | sort -h
    fi
}

isatty()
{
    # Test whether stdout is a terminal.
    tty -s 0<&1
}

diffwrap()
{
    colordiff=$(type -P colordiff)
    if isatty && test -n "$colordiff"; then
        command diff "$@" | colordiff
    else
        command diff "$@"
    fi
}
alias diff='diffwrap'

mountwrap()
{
    if [ -z "$1" ]; then
        command mount | column -t
    else
        command mount "$@"
    fi
}
alias mount='mountwrap'

mounts()
{
    command mount | cut -d ' ' -f 1,3,5 | column -t
}

alias mk='makewrap -j quiet=yes'
alias mkv='makewrap -j quiet='
alias mkd='makewrap -j buildtag=debug quiet=yes'
alias mkdv='makewrap -j buildtag=debug quiet='

alias mr='mrwrap'
alias mrs='mr st'

# Reverse "mv".
# Useful to undo a rename.
rmv()
{
    if [ $# != 2 ]; then
        cat <<EOF
rmv DESTFILE SRCFILE
"mv" with reversed source/destination.  Useful for reversing the
effects of a rename.
EOF
        return 2
    fi
    mv "$2" "$1"
}

# History with searching and optional paging or truncation to one screen.
h()
{
    if [ $# -gt 0 ]; then
        history | grep "$@"
    else
        history
    fi |
    if isatty; then
        tail -n 20
    else
        cat
    fi
}

##############################################################################
# Support for $HOME in Git.
alias homegit='GIT_DIR=~/.home.git GIT_WORK_TREE=~  git'
alias home2git='GIT_DIR=~/.home2.git GIT_WORK_TREE=~  git'

##############################################################################
# Python support

if [ -n "$(command -v virtualenvwrapper.sh)" ]; then
    . virtualenvwrapper.sh
fi

##############################################################################
# Enable completion support.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

##############################################################################
# Readline key bindings and settings.
# Syntax: "\e" means escape.  Bash sends Alt-x as Escape-x ==> "\ex".
# Bind keys to a macro value:
#   bind '"keys" : "value"'
# Bind keys to execute a Bash command/function/etc.:
#   bind -x '"keys" : commands'
# Set readline variables:
#   bind 'set variable value'

# Readline variables.

# These two settings eliminate the need to press <Tab>
# twice when completing a symlink to a directory:
bind 'set mark-directories On'
bind 'set mark-symlinked-directories On'

# Experimental: If completions are longer than this, use '...' as prefix.
bind 'set completion-prefix-display-length 4'

# Readline key bindings.

## Use vi-compatible editing.
#set -o vi
## In insert-mode, bring over many Emacs bindings.
#bind -m vi-insert '"\eb": backward-word'
#bind -m vi-insert '"\e\C-?": backward-kill-word'
#bind -m vi-insert '"\C-a": beginning-of-line'
#bind -m vi-insert '"\C-l": clear-screen'
#bind -m vi-insert '"\C-d": delete-char'
#bind -m vi-insert '"\C-x\C-e": edit-and-execute-command'
#bind -m vi-insert '"\C-e": end-of-line'
#bind -m vi-insert '"\C-s": forward-search-history'
#bind -m vi-insert '"\ef": forward-word'
#bind -m vi-insert '"\C-p": history-search-backward'
#bind -m vi-insert '"\C-n": history-search-forward'
#bind -m vi-insert '"\e.": yank-last-arg'
#bind -m vi-insert '"\C-k": kill-line'
#bind -m vi-insert '"\ed": kill-word'
#bind -m vi-insert '"\C-r": reverse-search-history'
#bind -m vi-insert '"\C-t": transpose-chars'
#bind -m vi-insert '"\et": transpose-words'
#bind -m vi-insert '"\C-u": unix-line-discard'
#bind -m vi-insert '"\C-w": unix-word-rubout'
#bind -m vi-insert '"\C-y": yank'


# CTRL-P/CTRL-N normally bind to previous-history/next-history.  These
# improved bindings are identical when the command line is empty, but
# when characters exist between the start of the current line and the
# "point" (i.e., cursor location), only results starting with that prefix
# will be returned.
bind -m emacs '"\C-p": history-search-backward'
bind -m emacs '"\C-n": history-search-forward'

# Macro key bindings.
# "Leader" key options:
#   Control-o
#   Control-g
# Something for find | xargs... ?
bind '"\C-o\C-o": "\C-e |& less\n"'
bind '"\C-o\C-l": "\C-a\edless\n"'
bind '"\C-o\C-f": "for i in *; do echo \"$''i\"; done"'
bind '"\C-o\C-i": "if [ -e \"$''i\" ]; then echo \"$''i\"; fi"'
bind '"\C-o\C-w": "while read i; do echo \"$''i\"; done"'
bind '"\C-o\C-r": "cd; root\n"'
bind '"\C-o\C-u": "cd ..\n"'

# Alt-l: perform ``ls`` without destroying in-progress editing.
bind -x '"\el": echo "[$''PWD]"; ls'

# Alt-u: cd ..
bind '"\eu": "cd ..\n"'

# Alt-s: "svn st" or "git st"
bind '"\es": "st\n"'

if [ -f "$HOME/.bashrc2" ]; then
    . "$HOME/.bashrc2"
fi
