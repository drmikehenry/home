if [ -z "$PROFILE_SOURCED" ]; then
    . /etc/profile
    . $HOME/.profile
fi
