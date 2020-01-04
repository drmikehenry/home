# True if $1 contains $2 as a substring.
__string_contains() {
    # If removing $2 from $1 makes a change, $1 contains $2.
    test "${1#*$2*}" != "$1"
}

pathcontains() {
    __string_contains ":$PATH:" ":$1:"
}

pathappend() {
    test -d "$1" && ! pathcontains "$1" && PATH="$PATH:$1"
}

pathprepend() {
    test -d "$1" && ! pathcontains "$1" && PATH="$1:$PATH"
}
