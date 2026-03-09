#!/bin/sh
set -eu

. "${0%/*}/_init.sh"

trap 'kill -KILL $(jobs -p) 2>/dev/null || true' EXIT INT HUP TERM

# Host to sandbox connection (slirp port forwarding)
export PORTS=18121:8000/tcp,
setsid sandbox-run python -m http.server 8000 &
pid=$!
sleep 2
curl 'http://127.0.0.1:18121' | grep -Fq '<title>Directory listing'
kill -- -$pid

## Guest to host connection (via 10.0.2.2 gateway) - DISABLED
python -m http.server 18123 &
! sandbox-run curl 'http://10.0.2.2:18123' 2>/dev/null
kill -KILL $!
