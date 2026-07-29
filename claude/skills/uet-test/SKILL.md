---
name: uet-test
description: Build and run the uet client/server test across the two Linux VMs. Builds the locally-edited code (synced via mutagen) on both the server VM (edavis@172.16.71.42) and client VM (edavis@172.16.71.13), runs ./scripts/uet_test.sh on each, and reports PASS/FAIL with full client+server output on failure. Use when the user wants to test, run, or verify the uet app, run the uet_test suite, or check that changes pass on the VMs. Works from any clone/fork under /Volumes/work/sync/uec.
argument-hint: "[--test all] [--pds pds] [--shim rawsock] [--build clean|make|none] [--build-only] [other overrides]"
allowed-tools: Bash(bash:*), Bash(~/.claude/skills/uet-test/run-uet-test.sh:*)
---

# uet-test

Build and run a uet client/server test across the two local Linux VMs, then
report the result.

## Background

- The app is a single binary, `uet`, that acts as both client and server. It
  only runs on Linux; code is edited locally on macOS and synced to both VMs by
  **mutagen** (local `/Volumes/work/sync` → remote `/home/edavis/sync`).
- A test requires a **server** and a **client** running on two different VMs,
  driven by the wrapper `./scripts/uet_test.sh`.
- The server must be listening before the client connects. The server process
  exits on its own once the client completes the run.
- Success prints `--> Done!`; failure prints `ERROR: Test failed!`.

## What the helper does

`run-uet-test.sh` orchestrates the whole run over SSH (passwordless key auth):

1. Waits a few seconds for mutagen to flush recent edits.
2. Runs `make clean && make` on **both** VMs in parallel. If either build fails,
   it prints that build's output and stops (exit 1).
3. Starts the **server** test in the background, waits a short delay, then runs
   the **client** test, and waits for both to finish.
4. Reports **PASS** (`--> Done!`) or **FAIL** (`ERROR: Test failed!`, or no Done
   marker). On failure it prints the **full client and server output**.

The remote working directory is derived from the local cwd by mapping
`/Volumes/work/sync` → `/home/edavis/sync`, so this works from any clone or fork.

## How to run

Run the helper from the repo the user is working in (its cwd determines the
remote directory). Pass through any overrides the user gave; otherwise use
defaults.

```bash
~/.claude/skills/uet-test/run-uet-test.sh
```

This is the equivalent of running, on the server VM:

```
./scripts/uet_test.sh server enp10s0 192.168.224.13 all pds rawsock
```

and on the client VM:

```
./scripts/uet_test.sh client enp10s0 192.168.224.42 all pds rawsock
```

### Defaults (override only what the user asks for)

| Flag | Default | Meaning |
|------|---------|---------|
| `--test` | `all` | test: `all`, `rma`, `sync_rma`, `atomic`, `sync_atomic`, `tag`, `tag_any_src`, `unexp_untag`, `unexp_tag`, `defer_send`, `defer_tag`, `defer_tag_any_src` |
| `--pds` | `pds` | pds: `all`, `sng`, `pds`, `pds_direct`, `pds_cluster`, `pds_cluster_ssi`, `pds_server_ssi` |
| `--shim` | `rawsock` | `rawsock` or `xdp` |
| `--ifname` | `enp10s0` | network interface on the VMs |
| `--build` | `make` | `make` (incremental; **default**), `clean` (make clean && make), or `none` (skip build) |
| `--build-only` | (off) | build both VMs then stop — skip the test (build OK → exit 0). Incompatible with `--build none` |
| `--server-ssh` | `edavis@172.16.71.42` | server VM (mgmt IP) |
| `--client-ssh` | `edavis@172.16.71.13` | client VM (mgmt IP) |
| `--server-peer` | `192.168.224.13` | client data-plane IP (server's peer) |
| `--client-peer` | `192.168.224.42` | server data-plane IP (client's peer) |
| `--remote-dir` | derived from cwd | remote working directory |
| `--settle-delay` | `5` | seconds to wait for mutagen before building |
| `--server-delay` | `2` | seconds between starting server and client |

Examples:

```bash
# Force a from-scratch rebuild of everything
~/.claude/skills/uet-test/run-uet-test.sh --build clean

# Run only the rma test with the xdp shim
~/.claude/skills/uet-test/run-uet-test.sh --test rma --shim xdp

# Faster iteration: don't rebuild, just rerun the test
~/.claude/skills/uet-test/run-uet-test.sh --build none

# Build-only pre-check: compile on both VMs, don't run the test
~/.claude/skills/uet-test/run-uet-test.sh --build-only
```

## Reporting back to the user

- The script's exit code: `0` = PASS (or, with `--build-only`, build succeeded),
  `1` = build failure, `2` = test FAIL, `3` = usage/ssh error.
- With **`--build-only`**, the script stops after a successful build (prints
  `RESULT: BUILD OK`) and exits `0` without running the test.
- On **PASS**, confirm success briefly (it already prints output tails).
- On **build failure**, surface the printed build error so the user can fix it.
- On **test FAIL**, the script prints the full client and server logs — review
  both, point out the error messages, and help diagnose the failure.
