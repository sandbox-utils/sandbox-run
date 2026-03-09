sandbox-run: run command in a secure OS sandbox
===============================================

[![Build status](https://img.shields.io/github/actions/workflow/status/sandbox-utils/sandbox-run/ci.yml?branch=master&style=for-the-badge)](https://github.com/sandbox-utils/sandbox-run/actions)
[![Language: shell / Bash](https://img.shields.io/badge/lang-Shell-peachpuff?style=for-the-badge)](https://github.com/sandbox-utils/sandbox-run)
[![Source lines of code](https://img.shields.io/endpoint?url=https%3A%2F%2Fghloc.vercel.app%2Fapi%2Fsandbox-utils%2Fsandbox-run%2Fbadge?filter=sandbox-run%26format=human&style=for-the-badge&label=SLOC&color=skyblue)](https://ghloc.vercel.app/sandbox-utils/sandbox-run)
[![Script size](https://img.shields.io/github/size/sandbox-utils/sandbox-run/sandbox-run?style=for-the-badge&color=skyblue)](https://github.com/sandbox-utils/sandbox-run)
[![Issues](https://img.shields.io/github/issues/sandbox-utils/sandbox-run?style=for-the-badge)](https://github.com/sandbox-utils/sandbox-run/issues)
[![Sponsors](https://img.shields.io/github/sponsors/kernc?color=pink&style=for-the-badge)](https://github.com/sponsors/kernc)


#### Problem statement

Running other people's programs is inherently insecure.
[Rogue dependencies](https://www.google.com/search?q=malicious+python+packages&tbm=nws)\*
🎯 or [hacked library code](https://www.google.com/search?q=(hacked+OR+hijacked+OR+backdoored+OR+"supply+chain+attack")+(npm+OR+pypi)&tbm=nws&num=100)
:pirate_flag: ([et cet.](https://slsa.dev/spec/draft/threats-overview) :warning:)
**can wreak havoc, including access all your private parts** :bangbang:—think
all current user's credentials and more personal bits like:
* `~/.ssh`,
* `~/.pki/nssdb/`,
* `~/.mozilla/firefox/<profile>/key4.db`,
* `~/.mozilla/firefox/<profile>/formhistory.sqlite` ...

<sub>✱ Running any
[Electron app](https://www.electronjs.org/apps)
relies on impeccability of hundreds or thousands of dependencies, NodeJS and Chromium to say the least! 😬</sub>

#### Solution

Run scary software in separate secure containers:
```shell
podman run --rm -it -v "$PWD:$PWD" --net=host --workdir="$PWD" debian:stable-slim ./scary-binary
```
or you can simply:
```shell
sandbox-run scary-binary
```
(e.g. `sandbox-run npx @google/gemini-cli`)
which relies on [**unshare**](https://manpages.debian.org/unstable/unshare) (from
`util-linux` package) to spawn your native OS container under the hood,
and, after downloading almost 500 MB ❗ of JavaScript sources,
executes this untrusted third-party's Node/NPM package anonymously and securely,
with its CWD in `$PWD` and new `$ROOT` (root fs /) in `$PWD/.sandbox`.

This script implements **most of the functionality of
[`bubblewrap`](https://github.com/containers/bubblewrap)
and [`firejail`](https://github.com/netblue30/firejail)**
(two well known Linux sandboxing tools that provide a secure,
isolated environment for running untrusted programs)
**in under ~500 lines of pure POSIX shell**.

You're on a terminal. There's nothing to build.
You run it. It works.

Installation
------------
On Linux, there are **no dependencies other than a POSIX shell** with
[its standard set of conventions and utilities](https://en.wikipedia.org/wiki/List_of_POSIX_commands).

The installation process might be similar on
[Windos/WSL](https://learn.microsoft.com/en-us/windows/wsl/install).
For macOS, see section **_Alternatives_** below.

```shell
# Install the unlikely-to-be-missing dependencies
sudo apt install mount coreutils util-linux

# Download the script and put it somewhere on PATH
curl -vL 'https://bit.ly/sandbox-run' | sudo tee /usr/local/bin/sandbox-run
sudo chmod +x /usr/local/bin/sandbox-run  # Mark executable

sandbox-run
# Usage: sandbox-run ARG...
sandbox-run ls /
```

Usage
-----
Whenever you want to run an untrusted executable, simply run:
```shell
sandbox-run scary-app args
```
to run `scary-app` in a secure sandbox.


#### Filesystem mounts

`"$PWD/.sandbox"` contains the sandbox root filesystem (/).

The **current working directory is mounted with read-write permissions**,
while everything else required for a successful run (e.g. /usr)
is mounted **read-only**.

To mount extra endpoints, use `RO_BIND=` and `RW_BIND=` environment variables.
Anything else not explicitly mounted is **lost upon namespace termination**.


#### Environment variables

[**`$PWD/.env` file (dotenv)**](https://stackoverflow.com/questions/68267862/what-is-an-env-or-dotenv-file-exactly)
is respected, sourced, and exported to the sandbox environment.

The following environment variables can be set to influence program behavior:

* **`ROOT=`**– Path to sandbox root filesystem (default: `$PWD/.sandbox`).
* **`RO_BIND=`**,
  **`RW_BIND=`**– Extra mount points to bind-mount read-only (or read-write respectively) inside the sandbox.
  Space- or, if argument paths themselves contain spaces, line-delimited.
  If any argument is like `src:dst`, path `src` is mounted as `dst` inside the sandbox.
* **`PORTS=`**– Space- or comma-separated list of ports to forward from host to guest.
  Format like for Docker/podman `-p` switch: `host_port:guest_port/protocol`.
  Example: `PORTS=8080:8080,8123:123/udp`.
* **`DEFAULT_RO_BIND=`**, **`DEFAULT_RW_BIND=`**– Override default mount points.
  Set clear to disable default mounts like `/usr` and `/lib`.
* **`VERBOSE=`**– Print to stderr verbose debug messages pertaining to sandbox initialization and cleanup.
* **`CLEANUP=`**– If set, remove `$ROOT` after execution.


#### Runtime monitoring

If **environment variable `VERBOSE=`** is set to a non-empty value,
verbose/debug program output is emitted to stderr upon execution.

You can list sandboxed processes using the
[command `lsns`](https://manpages.debian.org/unstable/lsns)
or the following shell function:

```sh
list_sandboxes () {
    lsns -u -W | {
        IFS= read header; echo "$header"
        grep --color=never "sandbox-run|slirp4netns"
    }
}

list_sandboxes  # Function call
```

You can run `sandbox-run` without arguments to spawn **interactive shell**.


#### Linux Seccomp

When the filter file exists, seccomp filtering is set up using
`setpriv --seccomp-filter="$ROOT/seccomp_filter.bin"`.
Default filtering is automatically set up if `enosys` is available (package `util-linux-extra`).
Most syscalls are allowed by default, but the dangerous ones are filtered out,
including all the
[syscalls blocked by Docker](https://docs.docker.com/engine/security/seccomp/).
```sh
sudo apt install util-linux-extra  # For enosys
# Optionally generate custom seccomp filter file
enosyss --dump='$PWD/.sandbox/seccomp_filter.bin' --syscall ...
```


#### Firejail profiles

Firejail profile in `$ROOT/firejail.profile` is read,
As this program is only a rudimentary Firejail approximation,
only directives `include`, `noblacklist`, `read-only` are interpreted.


#### Debugging

To see what's failing, run the sandbox with something like `colorstrace -f -e '%file,%process' ...`.


Examples
--------
To pass extra environment variables, other than those filtered by default,
use `.env` file:
```sh
echo 'OPENAI_API_KEY=1111111111' > .env
sandbox-run my-ai-prog
```

To run the sandboxed process as **superuser**
(while still retaining most of the security functionality of the container sandbox),
e.g. to open privileged ports, simply use `sudo`:
```sh
sudo sandbox-run python -m http.server 80
```

To run **GUI (X11) apps**, some prior success was achieved using e.g.:
```sh
RO_BIND='/tmp/.X11-unix/X0:/tmp/.X11-unix/X8' DISPLAY=:8 \
    sandbox-run xterm
```


Contributing
------------
You see a mistake—you fix it. Thanks!


Alternatives
------------
See a few alternatives discussed over at sister project
[`sandbox-venv`](https://github.com/sandbox-utils/sandbox-venv/#Viable-alternatives).
