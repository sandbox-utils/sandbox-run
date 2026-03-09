#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

sandbox-run sh -c 'echo foo > bar' && grep -q foo bar

if [ "${CI-}" ]; then
    rm -rf ./.sandbox  # First remove another user's .sandbox dir
    sudo --preserve-env "$(command -v sandbox-run)" sh -c 'echo foo > baz' &&
        sudo grep -q foo baz
    sudo rm -rf ./.sandbox
fi
