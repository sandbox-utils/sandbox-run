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
or you can simply 
`sandbox-run scary-binary`
which uses [**bubblewrap**](https://github.com/containers/bubblewrap) (of
[Flatpak](https://en.wikipedia.org/wiki/Flatpak) fame) to spawn your native OS container under the hood.


Installation
------------
There are **no dependencies other than a POSIX shell** with
[its standard set of utilities](https://en.wikipedia.org/wiki/List_of_POSIX_commands)
**and `bubblewrap`**.
The installation process, as well as the script runtime,
should behave similarly on all relevant compute platforms,
including GNU/Linux and even
[Windos/WSL](https://learn.microsoft.com/en-us/windows/wsl/install). 🤞

```shell
# Install the few, unlikely to be missing dependencies, e.g.
sudo apt install coreutils binutils bubblewrap

# Download the script and put it somewhere on PATH
curl -vL 'https://bit.ly/sandbox-run' | sudo tee /usr/local/bin/sandbox-run
sudo chmod +x /usr/local/bin/sandbox-run  # Mark executable

sandbox-run
# Usage: sandbox-run ARG...
sandbox-run ls /
```

Usage
-----
Whenever you want to run a scary executable, simply run:
```shell
sandbox-run scary-app args
```
to run `scary-app` in a secure sandbox.


#### Extra Bubblewrap arguments

You can also pass additional bubblewrap arguments to individual
process invocations via **`$BWRAP_ARGS` environment variable**. E.g.:

```sh
BWRAP_ARGS='--bind /opt /opt' \
    sandbox-run ./NVIDIA-Driver-Installer.run
```

For details, see `bubblewrap --help` or [`man 1 bwrap`](https://manpages.debian.org/unstable/bwrap).

Note, **[`.env` file](https://stackoverflow.com/questions/68267862/what-is-an-env-or-dotenv-file-exactly)
at project root** is respected, and sourced for the sandbox environment.

See more specific examples below.


#### Filesystem mounts

The **current working directory is mounted with read-write permissions**,
while everything else required for a successful run (e.g. /usr)
is mounted **read-only**. In addition:

* `"$PWD/.sandbox-home"` is bind-mounted as `"$HOME"`,

To mount extra endpoints, use `BWRAP_ARGS=` with switches `--bind` or `--bind-ro`.
Anything else not explicitly mounted by an extra CLI switch
is **lost upon container termination**.


#### Linux Seccomp

See `bwrap` switches [`--seccomp FD` and `--add-seccomp-fd FD`](https://manpages.debian.org/unstable/bubblewrap/bwrap.1.en.html#:~:text=Lockdown%20options%3A-,--seccomp%20fd,-Load%20and%20use).


#### Runtime monitoring

If **environment variable `VERBOSE=`** is set to a non-empty value,
the full `bwrap` command line is emitted to stderr before execution.

You can list bubblewraped processes using the
[command `lsns`](https://manpages.debian.org/unstable/lsns)
or the following shell function:

```sh
list_bwrap () { lsns -u -W | { IFS= read header; echo "$header"; grep bwrap; }; }

list_bwrap  # Function call
```

You can run `sandbox-run bash` to spawn **interactive shell inside the sandbox**.


#### Environment variables

* `BWRAP_ARGS=`– Extra arguments passed to `bwrap` process; space or line-delimited (if arguments such as paths themselves contain spaces).
* `SANDBOX_RO_BIND=`– List of additional path glob expressions to mount read-only inside the sandbox.
* `VERBOSE=`– Print full `exec bwrap` command line right before execution.


#### Debugging

To see what's failing, run the sandbox with something like `colorstrace -f -e '%file,%process' ...`.


Examples
--------
To pass extra environment variables, other than those filtered by default,
use `bwrap --setenv`, e.g.:
```sh
BWRAP_ARGS='--setenv OPENAI_API_KEY c4f3b4b3'  sandbox-run my-ai-prog
# or pass via .env (dotenv) file
```

To run the sandboxed process as **superuser**
(while still retaining all the security functionality of the container sandbox),
e.g. to open privileged ports, use args:
```sh
BWRAP_ARGS='--uid 0 --cap-add cap_net_bind_service' sandbox-run python -m http.server 80
```

To run **GUI (X11) apps**, some prior success was achieved using e.g.:
```sh
BWRAP_ARGS='--bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X8 --setenv DISPLAY :8' \
    sandbox-run python -m tkinter
```
See [more examples on the ArchWiki](https://wiki.archlinux.org/title/Bubblewrap#Using_X11).


Contributing
------------
You see a mistake—you fix it. Thanks!


Viable alternatives
-------------------
See a few alternatives discussed over at sister project
[`sandbox-venv`](https://github.com/sandbox-utils/sandbox-venv/#Viable-alternatives).
