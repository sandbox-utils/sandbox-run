#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

SANDBOX_RO_BIND='/etc/shad*,/etc/motd*' \
    sandbox-run sh -c 'test -f /etc/shadow; test -f /etc/motd'
