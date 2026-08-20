---
name: uet-matrix
description: Run the UET test matrix across two suites and both address families on the two Linux VMs, or a selected subset. Suite "verbs" = ibv_ru_rma / ibv_ru_pingpong via the uet-verbs-test harness (rdma-core uprot provider): every feature axis (app-specified vs provider-assigned QPN, symmetric/asymmetric/absolute addressing, plain/derived/job/user-key MRs, address table, 64/32-bit keys, legacy vs builder ops, multi-SGE, 32/64-bit immediates). Suite "refprov" = ./scripts/uet_test.sh via the uet-test harness (uet-ref-prov standalone ./uet app): one cell per PDS/security mode (sng, pds, pds_direct, pds_cluster, pds_cluster_ssi, pds_server_ssi), each running all test types, shim=rawsock. Both suites sweep IPv4 (GID 1) and IPv6 link-local (GID 0), reporting per-cell PASS/FAIL and a final TOTAL. Use when the user wants to run the test matrix, the full compliance sweep, all the tests, IPv4+IPv6 coverage, the verbs and/or ref-prov suites; to list the available tests; to run one/some tests; or to dump the exact per-test command lines. IPv6 link-local peers are discovered dynamically from each VM's data-plane interface. Works from any clone/fork under /Volumes/work/sync/uec: the verbs suite tests whichever repo the current working directory is in (the remote dir is derived from cwd, with no hardcoded fallback), so cd to the fork you want to test before running.
argument-hint: "[--list] [--debug] [--suite verbs|refprov|both] [--family v4|v6|both] [--build clean|make|none] [--iters N] [--timeout S] [TEST ...]"
allowed-tools: Bash(bash:*), Bash(~/.claude/skills/uet-matrix/run-uet-matrix.sh:*)
---

# uet-matrix

Run the UET test matrix on the two local Linux VMs, or just the cells the user
asks for, across **two suites** and **both address families**. This skill owns
the *catalog* of cells, the *suite* + *family* sweep, and the *selection*,
*list*, and *debug* modes; each cell is one call into the appropriate per-cell
harness (which does the build + client/server run).

## Suites

- **verbs** — `ibv_ru_rma` / `ibv_ru_pingpong` via the **uet-verbs-test** skill
  (rdma-core `uprot` provider). **27 cells** (`R01`–`R14` RMA, `P01`–`P13`
  pingpong) exercising every feature axis, including the 32-bit and 64-bit
  memory-key paths. Addressing: IPv4 = `-g 1`, IPv6
  link-local = `-g 0`; the client dials the server's link-local for v6.
- **refprov** — `./scripts/uet_test.sh` via the **uet-test** skill (the
  uet-ref-prov standalone `./uet` app). **6 cells**, one per PDS/security mode:
  `sng`, `pds`, `pds_direct`, `pds_cluster`, `pds_cluster_ssi`,
  `pds_server_ssi`. Each cell runs **all** test types (`test=all`) with
  `shim=rawsock`. Addressing is peer-to-peer (each side dials the other's
  data-plane address; link-local for v6).

A full sweep is **both suites × both families** = (27+6) × 2 = **66 cells**.

## Background

- **Family → GID index** (verbs suite, from the uprot kmod / `ibv_devinfo`):
  IPv4 = `-g 1`, IPv6 link-local = `-g 0`.
- **IPv6 peers are discovered at runtime** (nothing hardcoded): the script
  SSHes to each VM, finds the interface bound to the data-plane IPv4 subnet
  (`192.168.224.x`), and reads that interface's `scope link` IPv6. The verbs
  suite needs only the **server's** link-local; the refprov suite needs **both**
  VMs' link-locals (each side dials the other). If a needed link-local can't be
  discovered, the affected v6 cells are skipped with a warning.
- **PASS** = the harness prints `RESULT: PASS` (verbs: both client+server exit 0;
  refprov: client shows `--> Done!` and neither side shows `ERROR: Test failed!`).
- Only the **first cell of each suite** builds (default `--build clean`, a
  from-scratch build on both VMs, avoiding the stale-partial-build failure mode);
  later cells in that suite reuse the binaries.

## Running it

Invoke the helper directly and pass the user's arguments through:

```
~/.claude/skills/uet-matrix/run-uet-matrix.sh [options] [TEST ...]
```

A full sweep is long-running (two clean builds + 54 client/server runs; the
refprov TSS cells are especially slow). Prefer running it in the **background**
and monitoring `/tmp/uet_matrix/summary.txt` for per-cell `-> RESULT:` lines and
the final `TOTAL:` line, rather than blocking. Per-cell logs are written to
`/tmp/uet_matrix/NNN-<label>.log`.

## Arguments

- `--suite verbs|refprov|both` / `-s` — which suite(s) to run (default `both`).
- `--family v4|v6|both` / `-f` — which address family(ies) (default `both`).
- `--list` / `-l` — print the catalog (both suites, grouped) and exit.
- `--debug` / `-d` — for the selected tests, print **the exact command lines** as
  **markdown** (a `##` section per cell with fenced `sh` blocks) and run nothing:
  the harness invocation (cut/paste to re-run that cell) **and** the real per-VM
  `ssh …` server/client commands (from each harness's own `--dry-run`, so they
  can't drift). Diagnostics go to stderr, so stdout is clean markdown — render it
  or redirect to a `.md` file.
- `--build clean|make|none` / `-b` — build mode for the **first cell of each
  suite** (later cells in that suite reuse the binaries). Default `clean`. `make`
  = fast incremental; `none` = skip building.
- `--iters N` / `-n` — verbs iterations per test (default 10).
- `--timeout S` / `-t` — verbs per-side hard cap seconds (default 90). Each
  refprov cell runs `test=all` and uses its own longer cap
  (`$UET_RP_TIMEOUT`, default 900).
- `TEST …` — run only matching cells. A `TEST` matches a cell's **base label**
  (`R01`, `pds_direct`), its **family:label** (`v6:R01`), a **family** (`v6`), or
  a **suite** (`verbs`, `refprov`). Quoted **globs** work: `'R*'`, `'pds_*'`,
  `'v6:*'`. With no `TEST`, every cell in the selected suite(s)/family(ies) runs.

## Examples

```
# full sweep: both suites, v4 + v6 — run in background, watch summary.txt
run-uet-matrix.sh

run-uet-matrix.sh --list              # what tests exist (both suites)
run-uet-matrix.sh -s refprov          # just the ref-prov suite (v4 + v6)
run-uet-matrix.sh -s verbs -f v6 R11  # one verbs cell, IPv6
run-uet-matrix.sh pds_server_ssi      # the TSS server-mode ref-prov cell (both fams)
run-uet-matrix.sh -f v4 'P0*'         # all IPv4 verbs pingpong cells
run-uet-matrix.sh -d -s refprov       # print ref-prov commands, run nothing
run-uet-matrix.sh -b make R03         # incremental build, run one cell
```

## Which repo gets tested

The **verbs** remote dir is **derived from the local cwd**, by mapping
`/Volumes/work/sync` → `/home/edavis/sync` (the same rule the `uet-verbs-test`
harness uses). So the matrix always tests the clone/fork you are sitting in —
run it from the repo you care about.

There is deliberately **no hardcoded fallback**. If the cwd is outside
`/Volumes/work/sync`, a run that includes the verbs suite aborts with exit 3
rather than quietly testing some other tree; a stale default would build the
wrong repo and report a clean `TOTAL: n/n PASS` that says nothing about your
changes. (`--list` and `--help` still work from anywhere.)

Both remote dirs are echoed to stderr at startup, e.g.

```
verbs remote dir  : /home/edavis/sync/uec/rdma-core.fork/wt_uet   [from: cwd]
refprov remote dir: /home/edavis/sync/uec/uet-ref-prov.fork/wt_pds
```

`[from: cwd]` vs `[from: UET_REMOTE_DIR]` tells you how it was chosen — check it
before trusting a result. The **refprov** suite lives in a different repo than
the cwd, so it keeps an explicit default (override with `UET_REFPROV_DIR`).

## Config (env overrides)

- `UET_RDMA_HARNESS` / `UET_REFPROV_HARNESS` — paths to the verbs / refprov
  harnesses (default the sibling skills `uet-verbs-test` / `uet-test`).
- `UET_REMOTE_DIR` — override the cwd-derived verbs remote dir (rdma-core
  `wt_uet`). Normally unnecessary; just `cd` to the fork you want to test.
- `UET_REFPROV_DIR` — ref-prov remote dir (`wt_pds`).
- `UET_LOCAL_ROOT` / `UET_REMOTE_ROOT` — the mutagen mapping used for the
  derivation (defaults `/Volumes/work/sync` and `/home/edavis/sync`).
- `UET_SERVER_SSH` / `UET_CLIENT_SSH` — the two VM ssh targets (for v6 discovery
  and, for refprov, peer addressing).
- `UET_DP_SUBNET` — data-plane IPv4 subnet used to locate the interface.
- `UET_SHIM` — refprov NIC shim (default `rawsock`).
- `UET_IFNAME` — refprov interface name on the VMs (default `enp10s0`).
- `UET_RP_TIMEOUT` — refprov per-cell cap seconds (default 900).
- `UET_MATRIX_OUT` — output dir for logs/summary (default `/tmp/uet_matrix`).
