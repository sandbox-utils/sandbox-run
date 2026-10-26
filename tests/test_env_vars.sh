#!/bin/sh
set -eu

. "${0%/*}/.init.sh"


MAKEFLAGS=-j8 sandbox-run sh -c 'set -u; echo $MAKEFLAGS'  # Harmless, built in
# Env file support
echo "FOOBAR_DOTENV=1" > .env
sandbox-run sh -c 'set -u; echo $FOOBAR_DOTENV'
# As FOOBAR_DOTENV is present in .env file, we permit overriding it via shell
FOOBAR_DOTENV=2 sandbox-run sh -c 'set -e; test $FOOBAR_DOTENV -eq 2'
# Sanity checks
sandbox-run sh -c 'set -u; echo $PWD'
! sandbox-run sh -c 'set -u; echo $NONEXISTENT' 2>/dev/null || exit 1
