#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

sandbox-run npm install dotenv

# Assert files exist
test -d node_modules/dotenv*
test -d .sandbox*/home/*/.npm
