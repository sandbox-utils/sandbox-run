#!/bin/sh
set -eux

. "${0%/*}/.init.sh"

# Mounts restored
mount="$(mount)"
sandbox-run ls
test "$mount" = "$(mount)"

# Test CLEANUP=
touch_file () { sandbox-run sh -c "touch ~/${0##*/}"; }
CLEANUP=1 touch_file
! test -f ".sandbox/$HOME/${0##*/}" || exit 1
# Sanity check
touch_file
test -f ".sandbox/$HOME/${0##*/}"
