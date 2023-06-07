#!/bin/sh

export PATH="$HOME/bin:/usr/local/bin:$PATH"
. $HOME/.keychain/$(hostname)-sh
unison -addversionno -ui text -sshargs -x "$@"
