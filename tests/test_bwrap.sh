#!/bin/sh
set -eux

. "${0%/*}/.init.sh"

sandbox-run.bwrap sh -c 'awk -V'  # Awk via /etc/alternatives

# Home is writable
sandbox-run.bwrap sh -c 'touch "$HOME/success"'
test -f ".sandbox-home/success"

# Test environment variables
VERBOSE=1 sandbox-run.bwrap sh -c ':' 2>&1 | grep -Fq 'exec bwrap'
BWRAP_ARGS='--setenv FOO bar' sandbox-run.bwrap sh -c 'test "$FOO" = "bar"'
sandbox-run.bwrap sh -c 'test ! -e /etc/environment'
! sandbox-run.bwrap sh -c 'test -e /etc/environment'
RO_BIND=/etc/environment sandbox-run.bwrap sh -c 'test -e /etc/environment'
