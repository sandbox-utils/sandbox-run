#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

sandbox-run sh -c echo

test ! -d .sandbox
