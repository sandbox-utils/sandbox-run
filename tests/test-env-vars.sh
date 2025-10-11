#!/bin/sh
set -eu

. "${0%/*}/_init.sh"


FOOBAR=1 sandbox-run sh -c 'set -u; echo $FOOBAR'
echo "FOOBAR_DOTENV=1" > .env
FOOBAR=1 sandbox-run sh -c 'set -u; echo $FOOBAR_DOTENV'
# Sanity checks
sandbox-run sh -c 'set -u; echo $PWD'
! sandbox-run sh -c 'set -u; echo $NONEXISTENT' 2>/dev/null
