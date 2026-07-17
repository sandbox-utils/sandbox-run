#!/bin/sh
set -eu

. "${0%/*}/.init.sh"

trap 'kill -KILL $(jobs -p) 2>/dev/null || true' EXIT INT HUP TERM

# Host to sandbox connection (slirp port forwarding)
PORTS=18121:18000/tcp \
sandbox-run python -m http.server 18000 &
sleep 1
curl 'http://127.0.0.1:18121' | grep -Fq '<title>Directory listing'
kill -KILL $!

# Host-to-guest when no PORTS => Could not connect to server
sandbox-run python -m http.server 18001 &
sleep 1
! curl 'http://127.0.0.1:18001' 2>/dev/null
kill -KILL $!

## Guest-to-host connection (via 10.0.2.2 gateway)
python -m http.server 18123 &
sleep 1
sandbox-run curl 'http://10.0.2.2:18123' | grep -Fq '<title>Directory listing'

# ... can also be disabled via SLIRP4NETNS_ARGS
code=0
if SLIRP4NETNS_ARGS=--disable-host-loopback \
        sandbox-run curl -v 'http://10.0.2.2:18123' 2>/dev/null; then
    code=1
fi
kill -KILL $!
exit $code
