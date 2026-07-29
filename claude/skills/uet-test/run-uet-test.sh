#!/usr/bin/env bash
#
# run-uet-test.sh — Build the uet app on the client+server VMs and run a test.
#
# The local source tree (under /Volumes/work/sync) is continuously synced to
# both VMs (under /home/edavis/sync) by mutagen. This script:
#
#   1. Waits a brief moment for mutagen to settle recent edits.
#   2. Runs `make clean && make` on BOTH VMs (in parallel). Aborts on any
#      build failure, printing the failing build log.
#   3. Starts the SERVER test in the background over SSH.
#   4. After a short delay, starts the CLIENT test over SSH (foreground).
#   5. Waits for both to finish (server exits on its own once the client is
#      done), then reports PASS/FAIL based on the output strings.
#
# Success marker in output: "--> Done!"
# Failure marker in output: "ERROR: Test failed!"
#
# Exit codes: 0 = PASS (or build-only build OK), 1 = build failure,
#             2 = test FAIL/unknown, 3 = usage/ssh error.

set -u

# ----------------------------------------------------------------------------
# Defaults (override via flags)
# ----------------------------------------------------------------------------
TEST="all"
PDS="pds"
SHIM="rawsock"
IFNAME="enp10s0"

SERVER_SSH="edavis@172.16.71.42"   # management IP, server VM
CLIENT_SSH="edavis@172.16.71.13"   # management IP, client VM

SERVER_PEER="192.168.224.13"       # data-plane IP of the CLIENT (server's peer)
CLIENT_PEER="192.168.224.42"       # data-plane IP of the SERVER (client's peer)

REMOTE_DIR=""                      # default: derived from $PWD
BUILD="make"                       # clean | make | none
BUILD_ONLY=0                       # 1 = build both VMs then stop (skip the test)
DRY_RUN=0                          # 1 = print the server/client ssh commands, run nothing
IMPAIRMENT=""                      # remote path to an imp_shim TOML (enables Tx drop/delay)
SETTLE_DELAY=5                     # seconds to let mutagen flush before building
SERVER_DELAY=2                     # seconds between starting server and client

# Local->remote path mapping (mutagen sync roots)
LOCAL_ROOT="/Volumes/work/sync"
REMOTE_ROOT="/home/edavis/sync"

SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new)
TEST_TIMEOUT=900                   # hard cap (seconds) on each side's test run

usage() {
    cat <<EOF
Usage: run-uet-test.sh [options]

Build the uet app on the client+server Linux VMs and run a client/server test
via ./scripts/uet_test.sh, then report PASS/FAIL. Local edits (under
/Volumes/work/sync) are synced to both VMs (/home/edavis/sync) by mutagen. Runs
from any clone/fork; the remote dir is derived from the local cwd.

PHASES (run over SSH, both VMs in parallel):
  1. settle  - wait ${SETTLE_DELAY}s for mutagen to flush recent edits
  2. build   - make clean && make on both VMs; aborts on failure (exit 1).
               --build make = incremental; --build none = skip build.
               --build-only stops here (build OK => exit 0), skipping the test.
  3. test    - server test in background, then client, via:
                 ./scripts/uet_test.sh server <ifname> <server-peer> <test> <pds> <shim>
                 ./scripts/uet_test.sh client <ifname> <client-peer> <test> <pds> <shim>
               PASS on "--> Done!"; FAIL on "ERROR: Test failed!" (or no marker).

OPTIONS:
  --test <t>          test: all rma rudi uud sync_rma atomic sync_atomic tag
                            tag_any_src unexp_untag unexp_tag defer_send
                            defer_tag defer_tag_any_src           (default: $TEST)
                            (test=all also runs a forced-RUDI rma pass and a
                             forced-UUD datagram pass on every pds* backend;
                             'rudi'/'uud' run standalone, pds only)
  --pds <p>           pds: all sng pds pds_direct pds_cluster pds_cluster_ssi
                           pds_server_ssi                        (default: $PDS)
  --shim <s>          shim: rawsock|xdp                          (default: $SHIM)
  --ifname <if>       network interface on the VMs               (default: $IFNAME)
  --server-ssh <u@h>  server VM ssh target                       (default: $SERVER_SSH)
  --client-ssh <u@h>  client VM ssh target                       (default: $CLIENT_SSH)
  --server-peer <ip>  client data-plane IP (server's peer)       (default: $SERVER_PEER)
  --client-peer <ip>  server data-plane IP (client's peer)       (default: $CLIENT_PEER)
  --remote-dir <p>    remote working dir                         (default: derived from \$PWD)
  --build <mode>      clean|make|none                            (default: $BUILD)
  --build-only        build both VMs then stop (skip the test)   (default: off)
  --dry-run           print the server/client ssh commands and stop (nothing run)
  --impairment <path> remote path to an imp_shim TOML; enables Tx packet drop/delay
                      (sets UET_IMPAIRMENT_SHIM on both VMs) to exercise retransmit
  --settle-delay <s>  mutagen settle secs                        (default: $SETTLE_DELAY)
  --server-delay <s>  server->client start gap                   (default: $SERVER_DELAY)
  --timeout <s>       per-side hard cap on the VMs               (default: $TEST_TIMEOUT)
  -h|--help           show this help and exit

EXAMPLES:
  # Default: incremental build + run the full test suite
  run-uet-test.sh

  # Force a from-scratch rebuild of everything
  run-uet-test.sh --build clean

  # Run only the rma test with the xdp shim
  run-uet-test.sh --test rma --shim xdp

  # Faster iteration: don't rebuild, just rerun the test
  run-uet-test.sh --build none

  # Build-only pre-check: compile on both VMs, don't run the test
  run-uet-test.sh --build-only

EXIT CODES:
  0 = PASS (or build-only build OK)   2 = test FAIL
  1 = build failure                   3 = usage/ssh error
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --test)        TEST="$2"; shift 2;;
        --pds)         PDS="$2"; shift 2;;
        --shim)        SHIM="$2"; shift 2;;
        --ifname)      IFNAME="$2"; shift 2;;
        --server-ssh)  SERVER_SSH="$2"; shift 2;;
        --client-ssh)  CLIENT_SSH="$2"; shift 2;;
        --server-peer) SERVER_PEER="$2"; shift 2;;
        --client-peer) CLIENT_PEER="$2"; shift 2;;
        --remote-dir)  REMOTE_DIR="$2"; shift 2;;
        --build)       BUILD="$2"; shift 2;;
        --build-only)  BUILD_ONLY=1; shift;;
        --dry-run)     DRY_RUN=1; shift;;
        --impairment)  IMPAIRMENT="$2"; shift 2;;
        --settle-delay) SETTLE_DELAY="$2"; shift 2;;
        --server-delay) SERVER_DELAY="$2"; shift 2;;
        --timeout)     TEST_TIMEOUT="$2"; shift 2;;
        -h|--help)     usage; exit 0;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 3;;
    esac
done

# GNU `timeout` (or `gtimeout` from coreutils) wraps each side's run as a
# backstop. macOS ships neither by default, so detect and gracefully skip
# (falling back to `env` as a harmless pass-through prefix). Using `env` rather
# than an empty array keeps this safe under bash 3.2 + `set -u`. Done after arg
# parsing so `--help` doesn't emit the NOTE below.
if command -v timeout >/dev/null 2>&1; then
    TIMEOUT_CMD=(timeout "$TEST_TIMEOUT")
elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_CMD=(gtimeout "$TEST_TIMEOUT")
else
    TIMEOUT_CMD=(env)
    echo "NOTE: no local 'timeout'/'gtimeout'; relying on the remote ${TEST_TIMEOUT}s per-side cap applied on the VMs." >&2
fi

# ----------------------------------------------------------------------------
# Derive the remote working directory from the local cwd if not given.
# ----------------------------------------------------------------------------
if [[ -z "$REMOTE_DIR" ]]; then
    case "$PWD" in
        "$LOCAL_ROOT"/*)
            REMOTE_DIR="${REMOTE_ROOT}/${PWD#"$LOCAL_ROOT"/}"
            ;;
        *)
            echo "ERROR: cwd ($PWD) is not under $LOCAL_ROOT; cannot derive remote dir." >&2
            echo "       Pass one explicitly with --remote-dir." >&2
            exit 3
            ;;
    esac
fi

WORKDIR="$(mktemp -d -t uet-test.XXXXXX)"
BUILD_SRV_LOG="$WORKDIR/build-server.log"
BUILD_CLI_LOG="$WORKDIR/build-client.log"
SRV_LOG="$WORKDIR/server.log"
CLI_LOG="$WORKDIR/client.log"

# Preserve the log files; just print their full paths on exit so they can be
# copy/pasted to view. (The WORKDIR is a mktemp dir under $TMPDIR; it persists
# until the OS cleans its temp area.)
show_logs() {
    echo
    echo "----- log files (preserved; copy/paste to view) ---------------"
    [[ -e "$BUILD_SRV_LOG" ]] && echo "  server build : $BUILD_SRV_LOG"
    [[ -e "$BUILD_CLI_LOG" ]] && echo "  client build : $BUILD_CLI_LOG"
    [[ -e "$SRV_LOG" ]] && echo "  server output: $SRV_LOG"
    [[ -e "$CLI_LOG" ]] && echo "  client output: $CLI_LOG"
}
trap show_logs EXIT

# Line-prefix a stream live, one "[LABEL] line" per input line. Uses awk with
# fflush() because macOS ships BSD sed (no `-u`) and no `stdbuf`, so this is the
# portable way to get unbuffered, line-by-line prefixing as output arrives.
prefix_stream() { awk -v p="$1" '{ print p, $0; fflush() }'; }

# Cap each side on the REMOTE (Linux) host, where `timeout` always exists — the
# local wrapper is absent on macOS. `-k 10` escalates to SIGKILL 10s after
# SIGTERM so a wedged run can't ignore the cap.
RUN_TIMEOUT="timeout -k 10 $TEST_TIMEOUT"
# Optional impairment shim: uet_test.sh reads UET_IMPAIRMENT_SHIM from its env
# and re-injects it into the app command, enabling Tx packet drop/delay.
IMPAIR_ENV=""
[[ -n "$IMPAIRMENT" ]] && IMPAIR_ENV="UET_IMPAIRMENT_SHIM='$IMPAIRMENT' "
SERVER_CMD="${IMPAIR_ENV}$RUN_TIMEOUT ./scripts/uet_test.sh server $IFNAME $SERVER_PEER $TEST $PDS $SHIM"
CLIENT_CMD="${IMPAIR_ENV}$RUN_TIMEOUT ./scripts/uet_test.sh client $IFNAME $CLIENT_PEER $TEST $PDS $SHIM"

case "$BUILD" in
    clean) MAKE_CMD="make clean && make";;
    make)  MAKE_CMD="make";;
    none)  MAKE_CMD="";;
    *) echo "ERROR: --build must be clean|make|none (got '$BUILD')" >&2; exit 3;;
esac

if [[ $BUILD_ONLY -eq 1 && "$BUILD" == "none" ]]; then
    echo "ERROR: --build-only with --build none has nothing to do." >&2
    exit 3
fi

echo "=============================================================="
echo " uet test run"
echo "   remote dir : $REMOTE_DIR"
echo "   build      : ${BUILD}$([[ $BUILD_ONLY -eq 1 ]] && echo '   (build-only: test skipped)')"
echo "   test/pds/shim : $TEST / $PDS / $SHIM   ifname: $IFNAME"
echo "   server     : $SERVER_SSH   (peer $SERVER_PEER)"
echo "   client     : $CLIENT_SSH   (peer $CLIENT_PEER)"
echo "=============================================================="

# --dry-run: print the exact server/client commands (copy/paste-able) and stop.
if [[ $DRY_RUN -eq 1 ]]; then
    echo ""
    echo "# ---- DRY RUN (nothing executed) ----"
    echo "# server ($SERVER_SSH):"
    echo "ssh $SERVER_SSH \"cd '$REMOTE_DIR' && $SERVER_CMD\""
    echo "# client ($CLIENT_SSH):"
    echo "ssh $CLIENT_SSH \"cd '$REMOTE_DIR' && $CLIENT_CMD\""
    exit 0
fi

# ----------------------------------------------------------------------------
# 1. Let mutagen settle.
# ----------------------------------------------------------------------------
if [[ "$SETTLE_DELAY" -gt 0 ]]; then
    echo "--> Waiting ${SETTLE_DELAY}s for mutagen sync to settle..."
    sleep "$SETTLE_DELAY"
fi

# ----------------------------------------------------------------------------
# 2. Build on both VMs in parallel.
# ----------------------------------------------------------------------------
if [[ -n "$MAKE_CMD" ]]; then
    echo "--> Building on server and client ($MAKE_CMD)..."
    ssh "${SSH_OPTS[@]}" "$SERVER_SSH" "cd '$REMOTE_DIR' && $MAKE_CMD" >"$BUILD_SRV_LOG" 2>&1 &
    bs_pid=$!
    ssh "${SSH_OPTS[@]}" "$CLIENT_SSH" "cd '$REMOTE_DIR' && $MAKE_CMD" >"$BUILD_CLI_LOG" 2>&1 &
    bc_pid=$!

    wait "$bs_pid"; bs_rc=$?
    wait "$bc_pid"; bc_rc=$?

    if [[ $bs_rc -ne 0 || $bc_rc -ne 0 ]]; then
        echo
        echo "ERROR: Build failed (server rc=$bs_rc, client rc=$bc_rc)."
        if [[ $bs_rc -ne 0 ]]; then
            echo "----- SERVER build output -------------------------------------"
            cat "$BUILD_SRV_LOG"
        fi
        if [[ $bc_rc -ne 0 ]]; then
            echo "----- CLIENT build output -------------------------------------"
            cat "$BUILD_CLI_LOG"
        fi
        exit 1
    fi
    echo "--> Build OK on both VMs."
fi

# ----------------------------------------------------------------------------
# 2b. Build-only pre-check: stop here (build succeeded) before running the test.
# ----------------------------------------------------------------------------
if [[ $BUILD_ONLY -eq 1 ]]; then
    echo
    echo "############################################################"
    echo "#  RESULT: BUILD OK  (--build-only; test skipped)"
    echo "############################################################"
    exit 0
fi

# ----------------------------------------------------------------------------
# 3. Start the server test in the background.
# ----------------------------------------------------------------------------
echo "--> Starting SERVER test..."
# Stream live to the terminal (prefixed) while keeping a clean, unprefixed copy
# in $SRV_LOG for grep. Wrapped in a function so the backgrounded job's exit
# status is ssh's (via PIPESTATUS[0]), not tee's/awk's — needed for the 124
# timeout check below.
run_server() {
    "${TIMEOUT_CMD[@]}" ssh "${SSH_OPTS[@]}" "$SERVER_SSH" \
        "cd '$REMOTE_DIR' && $SERVER_CMD" 2>&1 \
        | tee "$SRV_LOG" | prefix_stream "[SRV]"
    return "${PIPESTATUS[0]}"
}
run_server &
srv_pid=$!

# ----------------------------------------------------------------------------
# 4. Short delay, then run the client test (foreground).
# ----------------------------------------------------------------------------
echo "--> Waiting ${SERVER_DELAY}s for server to come up..."
sleep "$SERVER_DELAY"

echo "--> Starting CLIENT test..."
"${TIMEOUT_CMD[@]}" ssh "${SSH_OPTS[@]}" "$CLIENT_SSH" \
    "cd '$REMOTE_DIR' && $CLIENT_CMD" 2>&1 \
    | tee "$CLI_LOG" | prefix_stream "[CLI]"
cli_rc="${PIPESTATUS[0]}"

# ----------------------------------------------------------------------------
# 5. Wait for server (it exits on its own once the client completes).
# ----------------------------------------------------------------------------
echo "--> Client finished (rc=$cli_rc); waiting for server to exit..."
wait "$srv_pid"; srv_rc=$?

if [[ $cli_rc -eq 124 || $srv_rc -eq 124 ]]; then
    echo "WARNING: a side hit the ${TEST_TIMEOUT}s timeout (client_rc=$cli_rc server_rc=$srv_rc)."
fi

# ----------------------------------------------------------------------------
# Evaluate result.
# ----------------------------------------------------------------------------
errored=0
if grep -qF "ERROR: Test failed!" "$CLI_LOG" "$SRV_LOG"; then
    errored=1
fi

done_ok=0
if grep -qF -- "--> Done!" "$CLI_LOG"; then
    done_ok=1
fi

echo
if [[ $errored -eq 0 && $done_ok -eq 1 ]]; then
    echo "############################################################"
    echo "#  RESULT: PASS  (--> Done!)"
    echo "############################################################"
    echo "----- CLIENT output (tail) ------------------------------------"
    tail -n 20 "$CLI_LOG"
    echo "----- SERVER output (tail) ------------------------------------"
    tail -n 20 "$SRV_LOG"
    exit 0
else
    echo "############################################################"
    if [[ $errored -eq 1 ]]; then
        echo "#  RESULT: FAIL  (ERROR: Test failed!)"
    else
        echo "#  RESULT: FAIL  (no '--> Done!' marker; client_rc=$cli_rc server_rc=$srv_rc)"
    fi
    echo "############################################################"
    echo
    echo "================ FULL CLIENT OUTPUT ==========================="
    cat "$CLI_LOG"
    echo
    echo "================ FULL SERVER OUTPUT ==========================="
    cat "$SRV_LOG"
    exit 2
fi
