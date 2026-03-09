#!/bin/sh
set -eux

. "${0%/*}/.init.sh"

sandbox-run sh -c 'awk -V'  # Awk via /etc/alternatives

# Home is writable
sandbox-run sh -c 'touch "$HOME/success"'
test -f ".sandbox/$HOME/success"
