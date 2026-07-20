#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

# Ensure /dev/fd/* is readable
sandbox-run bash -c 'diff <(echo foo) <(echo foo)'

