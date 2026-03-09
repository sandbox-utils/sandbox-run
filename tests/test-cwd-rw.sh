#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

sandbox-run sh -c 'echo foo > bar' && grep -q foo bar

if [ "${CI-}" ]; then
    sudo "$(command -v sandbox-run)" sh -c 'echo foo > baz' &&
        sudo grep -q foo baz
fi
