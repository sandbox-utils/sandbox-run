#!/bin/sh

PS4="$(
    if [ "${LINENO:-}" ] && [ "${BASH_VERSION:-}" ]; then lineno=':${LINENO-}>'; fi
    printf "\033[34;40;1m+%s${lineno:-} \033[31;1m[%s]\033[0m " "$0" '$?'
)"
export PS4
set -eux

LC_ALL=C
tmpdir="$(mktemp -d -t sandbox-run_test-XXXXXXX)"
# shellcheck disable=SC2064
trap "tree -a -L 4 --si --du '$tmpdir'; rm -fvr '$tmpdir'; trap - INT HUP EXIT TERM" INT HUP TERM EXIT
if [ ! "${CI-}" ]; then case "$tmpdir" in /tmp*|/var/*) ;; *) exit 9 ;; esac; fi

PATH="$(pwd):$PATH"
#HOME="$tmpdir"
cd "$tmpdir"
