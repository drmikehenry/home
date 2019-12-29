pathappend() {
    test -d "$1" && PATH="$PATH:$1"
}

pathprepend() {
    test -d "$1" && PATH="$1:$PATH"
}
