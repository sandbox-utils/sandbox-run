#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

ln -s "$(command -v sandbox-run)" npm
PATH="$(pwd):$PATH"

npm --version 2>&1 | grep -q 'sandbox-run'
npm --help | grep -q 'install'
