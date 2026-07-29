---
name: uet-verbs-test
description: Build and run the uet RDMA client/server test across the two Linux VMs. Builds the locally-edited code (synced via mutagen) on both the server VM (edavis@172.16.71.42) and client VM (edavis@172.16.71.13) — uet-ref-prov dependency, RDMA apps, and the uprot kmod — ensures the uprot rdma device is up, then runs the ibv_ru_pingpong or ibv_ru_rma test binary on each and reports PASS/FAIL (both sides exit 0) with full client+server output on failure. Use when the user wants to test, run, or verify the uet RDMA app (ibv_ru_pingpong / ibv_ru_rma), or check that changes pass on the VMs. Works from any clone/fork under /Volumes/work/sync/uec.
argument-hint: "[--app pingpong|rma] [--rma-test rma_ex64] [--app-args \"<flags>\"] [--server-app-args \"<flags>\"] [--client-app-args \"<flags>\"] [--build clean|make|none] [--build-only] [--reload]"
allowed-tools: Bash(bash:*), Bash(~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh:*)
---

# uet-verbs-test

Build and run a uet client/server test across the two local Linux VMs, then
report the result.

## Background

- The RDMA test apps are `build/bin/ibv_ru_pingpong` and `build/bin/ibv_ru_rma`;
  each acts as both client and server. They only run on Linux; code is edited
  locally on macOS and synced to both VMs by **mutagen** (local
  `/Volumes/work/sync` → remote `/home/edavis/sync`).
- The RDMA test apps in this repo **depend on the uet-ref-prov repo**
  (`libuet_verbs.so`). So the build is **three stages** per VM: first build
  uet-ref-prov (`make clean && make`), then build the RDMA apps
  (`UET_REF_PROV_PATH=<ref-prov> ./build.sh`), then build the uprot **kernel
  module** in `providers/uprot/kmod` (`make clean && make`) that enables rdma
  device discovery/open.
- Each binary runs under `sudo` with the ref-prov lib on `LD_LIBRARY_PATH` and
  the `UET_PDS` env var set (`--pds`). The **server** runs with no `<host>`
  (just listens); the **client** runs with the server's data-plane IP
  (`--client-peer`, default `192.168.224.42`) as its connect target.
- The server must be listening before the client connects. The server process
  exits on its own once the client completes the run.
- **PASS iff both the client and server processes exit 0.** `-c` (validate
  received buffer) is always passed, so a data mismatch makes the binary exit
  nonzero.

## What the helper does

`run-uet-verbs-test.sh` orchestrates the whole run over SSH (passwordless key auth):

1. Waits a few seconds for mutagen to flush recent edits.
2. Builds on **both** VMs in parallel, three stages per VM (each stage only runs
   if the previous one succeeds). If either VM's build fails, it prints that
   build's output and stops (exit 1):
   - **stage 1** — `make clean && make` in the uet-ref-prov dir (the dependency)
   - **stage 2** — `UET_REF_PROV_PATH=<ref-prov> ./build.sh` in the RDMA repo dir
     (`--build clean` also `rm -rf build` first for a from-scratch RDMA build)
   - **stage 3** — `make clean && make` in `providers/uprot/kmod` (the uprot
     kernel module for rdma device discovery/open)
3. Ensures the **uprot rdma device** on **both** VMs in parallel (needed before
   the app can run). By default this is *ensure-present*: load the kmod
   (`sudo insmod rdma_uprot.ko`) and create the device
   (`sudo rdma link add uprot0 type uprot netdev <ifname>`) only if missing,
   leaving an existing setup untouched. With `--reload` it first tears down
   (`sudo rdma link delete uprot0` + `sudo rmmod rdma_uprot`) then recreates,
   e.g. to pick up a freshly-built module. It verifies via `lsmod` +
   `ibv_devices`; if the device isn't present afterward it prints both VMs'
   setup output and stops (exit 4).
4. Starts the **server** test binary (`--app`, default `ibv_ru_pingpong`) in the
   background, waits a short delay, then runs the **client** (same binary, with
   the server's data-plane IP appended), and waits for both to finish.
5. Reports **PASS** (both sides exit 0) or **FAIL** (either exits nonzero). On
   failure it prints the **full client and server output** (exit 2).

The remote working directory is derived from the local cwd by mapping
`/Volumes/work/sync` → `/home/edavis/sync`, so this works from any clone or fork.

## How to run

Run the helper from the repo the user is working in (its cwd determines the
remote directory). Pass through any overrides the user gave; otherwise use
defaults.

```bash
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh
```

This is the equivalent of running, on the server VM:

```
sudo LD_LIBRARY_PATH=<remote-dir>/build/lib UET_PDS=pds \
    build/bin/ibv_ru_pingpong -d uprot0 -g 1 -s 64 -n 10000 -e -c
```

and on the client VM (dialing the server's data-plane IP):

```
sudo LD_LIBRARY_PATH=<remote-dir>/build/lib UET_PDS=pds \
    build/bin/ibv_ru_pingpong -d uprot0 -g 1 -s 64 -n 10000 -e -c 192.168.224.42
```

For `--app rma`, the binary is `ibv_ru_rma` and `-t <rma-test>` (default
`rma_ex64`) is added on **both** sides.

### Defaults (override only what the user asks for)

| Flag | Default | Meaning |
|------|---------|---------|
| `--app` | `pingpong` | which test binary: `pingpong` (ibv_ru_pingpong) or `rma` (ibv_ru_rma) |
| `--pds` | `pds` | `UET_PDS` env value (used by `libuet_verbs.so`) |
| `--size` | `64` | `-s` message size |
| `--iters` | `10000` | `-n` number of exchanges |
| `--gid-idx` | `1` | `-g` local port gid index |
| `--rma-test` | `rma_ex64` | `-t` for `--app rma` only: `rma`, `rma_ex`, or `rma_ex64` (both sides) |
| `--no-events` | (off) | disable `-e` (CQ events are **on** by default) |
| `--new-send` | (off) | add `-N` (new post-send WR API; `--app pingpong` only) |
| `--app-args "<flags>"` | (none) | extra app flags appended to **both** sides |
| `--server-app-args "<flags>"` | (none) | extra app flags appended to the **server** only |
| `--client-app-args "<flags>"` | (none) | extra app flags appended to the **client** only |
| `--ifname` | `enp10s0` | network interface used as the rdma device netdev |
| `--uet-ref-prov-dir` | `/home/edavis/sync/uec/uet-ref-prov.fork/wt_pds` | uet-ref-prov dependency dir (stage 1 build + `UET_REF_PROV_PATH`) |
| `--build` | `make` | `make` (incremental both stages; **default**), `clean` (ref-prov `make clean && make` + RDMA `rm -rf build && ./build.sh`), or `none` (skip build) |
| `--build-only` | (off) | build all stages on both VMs then stop — skip device setup and the test (build OK → exit 0). Incompatible with `--build none` |
| `--rdma-dev` | `uprot0` | uprot rdma device name (`-d`); created on both VMs |
| `--reload` | off | force teardown (`rdma link delete` + `rmmod`) and recreate of the kmod + rdma device (otherwise only created if missing) |
| `--server-ssh` | `edavis@172.16.71.42` | server VM (mgmt IP) |
| `--client-ssh` | `edavis@172.16.71.13` | client VM (mgmt IP) |
| `--server-peer` | `192.168.224.13` | client's data-plane IP (not consumed by the binaries) |
| `--client-peer` | `192.168.224.42` | server's data-plane IP — the client dials this |
| `--remote-dir` | derived from cwd | remote working directory |
| `--settle-delay` | `5` | seconds to wait for mutagen before building |
| `--server-delay` | `2` | seconds between starting server and client |

Examples:

```bash
# Default: incremental build + ensure device + run ibv_ru_pingpong
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh

# Force a from-scratch rebuild of everything
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --build clean

# Run ibv_ru_rma with the rma_ex test type
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --app rma --rma-test rma_ex

# Pingpong with the new post-send WR API and polling (no CQ events)
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --new-send --no-events

# Faster iteration: don't rebuild, just rerun the test
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --build none

# Build-only pre-check: compile all stages on both VMs, skip device + test
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --build-only

# Force-reload the freshly-built kmod + rdma device before testing
~/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh --reload
```

## Forwarding arbitrary app flags

The dedicated options above cover the common knobs; **any** other example-app
flag is forwarded verbatim via the passthroughs. Use `--app-args` for a flag that
should apply to both sides, and `--server-app-args` / `--client-app-args` when the
two sides need **different** flags (e.g. distinct JobIDs for the absolute test).
`--server-peer`/`--client-peer`/`-d`/`-g`/`-s`/`-n`/`-e`/`-c`/`-t` are already
handled by the harness; passing a duplicate in a passthrough just overrides it
(the apps use `getopt`).

Full flag set of the underlying binaries:

| App | Flags |
|-----|-------|
| `ibv_ru_rma` | `-p <port>` `-d <dev>` `-i <ibport>` `-s <size>` `-m <mtu>` `-r <rxdepth>` `-n <iters>` `-e` `-g <gididx>` `-c` `-t <rma\|rma_ex\|rma_ex64>` `-Q` (auto-qpn) `-D` (derive-mr) `-A` (addr-table) `-J` (job-mr) `-u <rkey>` (user-assigned RKey) `-b` (absolute) `-j <jobid>` |
| `ibv_ru_pingpong` | `-p` `-d` `-i` `-s` `-m` `-r` `-n` `-e` `-g` `-c` `-N` (new-send) `-Q` (auto-qpn) `-I <32\|64>` (SEND with immediate) |

Examples:

```bash
# rma feature flags (both sides)
run-uet-verbs-test.sh --app rma --app-args "-J"        # job-restricted MR
run-uet-verbs-test.sh --app rma --app-args "-u 13"     # user-assigned RKey
run-uet-verbs-test.sh --app rma --app-args "-D"        # derived MR
run-uet-verbs-test.sh --app rma --app-args "-A"        # job address table

# pingpong SEND-with-immediate (32b or 64b)
run-uet-verbs-test.sh --app pingpong --app-args "-I 64"

# absolute addressing: server and client need DISTINCT JobIDs -> per-side args
run-uet-verbs-test.sh --app rma \
    --server-app-args "--absolute --job-id 46" \
    --client-app-args "--absolute --job-id 47"
```

## Reporting back to the user

- The script's exit code: `0` = PASS (or, with `--build-only`, build succeeded),
  `1` = build failure, `2` = test FAIL, `3` = usage/ssh error, `4` = uprot device
  setup failure.
- With **`--build-only`**, the script stops after a successful build (prints
  `RESULT: BUILD OK`) and exits `0` without device setup or running the test.
- On **PASS**, confirm success briefly (it already prints output tails).
- On **build failure**, surface the printed build error so the user can fix it.
- On **device setup failure**, the script prints both VMs' setup output — check
  whether the kmod loaded (`insmod`/`rmmod`) and the `rdma link add` succeeded.
- On **test FAIL**, the script prints the full client and server logs — review
  both, point out the error messages, and help diagnose the failure.
