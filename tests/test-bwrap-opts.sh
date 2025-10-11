#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

BWRAP_ARGS='--ro-bind /etc/os-release /file' sandbox-run cat /file
