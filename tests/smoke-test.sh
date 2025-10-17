#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

sandbox-run sh -c 'awk -V'  # Awk via /etc/alternatives

sandbox-run sh -c 'touch "$HOME/success"'

test -f .sandbox*/success  # Assert file exists
