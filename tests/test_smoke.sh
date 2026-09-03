#!/bin/sh
set -eux

. "${0%/*}/.init.sh"

# Awk works via /etc/alternatives
sandbox-run sh -c 'awk -V | grep -Fq "GNU Awk"'

# Home is writable
sandbox-run sh -c 'touch "$HOME/success"'
test -f ".sandbox/$HOME/success"

# Safety test
# /proc is private
test "$(sandbox-run ps -e | tee /dev/stderr | wc -l)" -lt 3

# HOME is not shared RW even if PWD
tmpdir="$(mktemp -d)"
(
    HOME="$tmpdir"
    cd "$HOME"
    sandbox-run sh -c 'touch "$HOME/base"'
)
! test -f "$tmpdir/base" || exit 1
! test -f ".sandbox/$tmpdir/base" || exit 1
