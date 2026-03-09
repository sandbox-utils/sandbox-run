#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

RO_BIND='/etc/shad* /etc/motd*' \
    sandbox-run sh -c 'test -f /etc/shadow; test -f /etc/motd'
