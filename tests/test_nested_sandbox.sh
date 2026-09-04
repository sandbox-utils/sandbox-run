#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

dir="$(command -v sandbox-run)" dir="${dir%/*}"
export RO_BIND="$dir"

sandbox-run sandbox-run sandbox-run sh -c 'echo success' |
    grep -q "success"
