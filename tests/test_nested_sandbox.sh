#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

sandbox-run sandbox-run sandbox-run sh -c 'echo success' |
    grep -q "success"

# Stable mount growth
count_script='mount | grep -c ".sandbox"'
n1="$(sandbox-run sh -c "$count_script" )"
n2="$(sandbox-run sandbox-run sh -c "$count_script")"
n3="$(sandbox-run sandbox-run sandbox-run sh -c "$count_script")"
test $((n2)) -le $((n1 + 2))
test $((n3)) -le $((n2 + 2))

# HOME is writable ...
sandbox-run sandbox-run sandbox-run sh -c 'echo foo > "$HOME/nest-success"'
# ... but levels deep, which is perfect.
test -f ".sandbox/.empty-sandbox/.empty-sandbox/$HOME/nest-success"
