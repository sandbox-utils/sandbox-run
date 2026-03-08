#!/bin/sh
set -eu

. "${0%/*}/_init.sh"


MAKEFLAGS=-j8 sandbox-run sh -c 'set -u; echo $MAKEFLAGS'  # Harmless, built in
# Env file support
echo "FOOBAR_DOTENV=1" > .env
sandbox-run sh -c 'set -u; echo $FOOBAR_DOTENV'
# Sanity checks
sandbox-run sh -c 'set -u; echo $PWD'
! sandbox-run sh -c 'set -u; echo $NONEXISTENT' 2>/dev/null
