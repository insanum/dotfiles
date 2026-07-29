#!/usr/bin/env bash
#
# run-uet-verbs-test.sh — Build the uet RDMA app on the client+server VMs and
# run a test.
#
# The local source tree (under /Volumes/work/sync) is continuously synced to
# both VMs (under /home/edavis/sync) by mutagen. This script:
#
#   1. Waits a brief moment for mutagen to settle recent edits.
#   2. Builds on BOTH VMs (in parallel), three stages per VM, aborting on any
#      failure and printing the failing build log:
#        stage 1: `make clean && make` in the uet-ref-prov dir (the dependency)
#        stage 2: `UET_REF_PROV_PATH=<ref-prov> ./build.sh` in the RDMA repo dir
#        stage 3: `make clean && make` in providers/uprot/kmod (the uprot
#                 kernel module for rdma device discovery/open)
#   3. Ensures the uprot rdma device on BOTH VMs (in parallel): loads the kmod
#      and creates the rdma link if missing; --reload forces a teardown+recreate
#      first. Verifies via lsmod + ibv_devices; aborts the run if not present.
#   4. Starts the SERVER test binary (build/bin/ibv_ru_pingpong or _ru_rma) in
#      the background over SSH.
#   5. After a short delay, starts the CLIENT test binary over SSH (foreground),
#      dialing the server's data-plane IP.
#   6. Waits for both to finish (server exits on its own once the client is
#      done), then reports PASS/FAIL: PASS iff BOTH sides exit 0.
#
# Each test binary runs as:
#   sudo LD_LIBRARY_PATH=<remote>/build/lib UET_PDS=<pds> build/bin/<app> \
#        -d <dev> -g <gid> -s <size> -n <iters> [-e] -c [-t <rma-test>|-N] [<host>]
#
# Exit codes: 0 = PASS (or build-only build OK), 1 = build failure,
#             2 = test FAIL/unknown, 3 = usage/ssh error,
#             4 = uprot device setup failure.

set -u

# ----------------------------------------------------------------------------
# Defaults (override via flags)
# ----------------------------------------------------------------------------
# Test-phase selection and arguments (the test binaries in build/bin).
APP="pingpong"                     # which test binary: pingpong | rma
PDS="pds"                          # UET_PDS env value (used by libuet_verbs.so)
IFNAME="enp10s0"                   # network interface (rdma device netdev)
SIZE=64                            # -s message size
ITERS=10000                        # -n number of exchanges
GID=1                              # -g local port gid index
RMA_TEST="rma_ex64"                # -t (ibv_ru_rma only): rma | rma_ex | rma_ex64
EVENTS=1                           # -e sleep on CQ events (on; disable w/ --no-events)
NEW_SEND=0                         # -N new post-send WR API (ibv_ru_pingpong only)
# Passthrough flags forwarded verbatim to the example app command line. These let
# the skill drive ANY flag the apps support without a dedicated option for each
# (ru_rma: -Q -D -A -J -u -b -j -m -r -p -c ...; ru_pingpong: -N -Q -I ...).
EXTRA_APP_ARGS=""                  # --app-args: appended to BOTH sides
SERVER_APP_ARGS=""                 # --server-app-args: appended to the SERVER only
CLIENT_APP_ARGS=""                 # --client-app-args: appended to the CLIENT only

SERVER_SSH="edavis@172.16.71.42"   # management IP, server VM
CLIENT_SSH="edavis@172.16.71.13"   # management IP, client VM

SERVER_PEER="192.168.224.13"       # data-plane IP of the CLIENT (server's peer)
CLIENT_PEER="192.168.224.42"       # data-plane IP of the SERVER (client's peer)

REMOTE_DIR=""                      # default: derived from $PWD
BUILD="make"                       # clean | make | none
BUILD_ONLY=0                       # 1 = build both VMs then stop (skip device + test)
DRY_RUN=0                          # 1 = print the server/client ssh commands, run nothing
SETTLE_DELAY=5                     # seconds to let mutagen flush before building
SERVER_DELAY=2                     # seconds between starting server and client

# uet-ref-prov dependency: built first (stage 1) and passed to the RDMA
# ./build.sh (stage 2) via UET_REF_PROV_PATH.
UET_REF_PROV_DIR="/home/edavis/sync/uec/uet-ref-prov.fork/wt_pds"

# uprot rdma device setup (runs after build, before the test). By default this
# is "ensure present": load the kmod / create the rdma device only if missing.
# --reload forces a full teardown (rdma link delete + rmmod) and recreate, e.g.
# to pick up a freshly-built module.
RDMA_DEV="uprot0"                  # rdma link device name (created on both VMs)
KMOD_NAME="rdma_uprot"             # kernel module name (lsmod/rmmod)
KMOD_KO="rdma_uprot.ko"            # built module file (in providers/uprot/kmod)
RELOAD=0                           # 1 = force reload of kmod + rdma device

# Local->remote path mapping (mutagen sync roots)
LOCAL_ROOT="/Volumes/work/sync"
REMOTE_ROOT="/home/edavis/sync"

SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new)
TEST_TIMEOUT=900                   # hard cap (seconds) on each side's test run

usage() {
    cat <<EOF
Usage: run-uet-verbs-test.sh [options]

Build the uet RDMA app on the client+server Linux VMs, ensure the uprot rdma
device is up, run a test binary on each, and report PASS/FAIL. Local edits
(under /Volumes/work/sync) are synced to both VMs (/home/edavis/sync) by mutagen.
Runs from any clone/fork; the remote dir is derived from the local cwd.

PHASES (run over SSH, both VMs in parallel):
  1. settle  - wait ${SETTLE_DELAY}s for mutagen to flush recent edits
  2. build   - three stages per VM, aborting on any failure (exit 1):
                 stage 1: make clean && make   in the uet-ref-prov dir
                 stage 2: UET_REF_PROV_PATH=<ref-prov> ./build.sh   (RDMA apps)
                 stage 3: make clean && make   in providers/uprot/kmod (kmod)
               --build make = incremental; --build none = skip build.
               --build-only stops after this phase (build OK => exit 0),
               skipping device setup and the test.
  3. device  - ensure the uprot kmod is loaded and the rdma device exists
               (insmod + rdma link add if missing). --reload forces a teardown
               (rdma link delete + rmmod) and recreate. Verified via lsmod +
               ibv_devices; aborts if not present (exit 4).
  4. test    - server binary in background, then client (dials the server's
               data-plane IP). Each runs as:
                 sudo LD_LIBRARY_PATH=<remote>/build/lib UET_PDS=<pds> \\
                      build/bin/<app> -d <dev> -g <gid> -s <size> -n <iters> \\
                      [-e] -c [-t <rma-test>|-N] [<host>]
               PASS iff BOTH sides exit 0 (-c always on: a data mismatch fails).

OPTIONS:
  --app <name>            test binary: pingpong|rma     (default: $APP)
  --pds <v>               UET_PDS env value             (default: $PDS)
  --size <n>              -s message size               (default: $SIZE)
  --iters <n>             -n number of exchanges        (default: $ITERS)
  --gid-idx <n>           -g local port gid index       (default: $GID)
  --rma-test <t>          -t rma only: rma|rma_ex|rma_ex64  (default: $RMA_TEST)
  --no-events             disable -e (CQ events; on by default)
  --new-send              -N new post-send WR API (pingpong only; default: off)
  --app-args "<flags>"        extra app flags appended to BOTH sides
  --server-app-args "<flags>" extra app flags appended to the SERVER only
  --client-app-args "<flags>" extra app flags appended to the CLIENT only
                          (forward ANY example-app flag; see APP FLAGS below)
  --ifname <if>           rdma device netdev            (default: $IFNAME)
  --server-ssh <u@h>      server VM ssh target          (default: $SERVER_SSH)
  --client-ssh <u@h>      client VM ssh target          (default: $CLIENT_SSH)
  --server-peer <ip>      client data-plane IP (unused by apps)    (default: $SERVER_PEER)
  --client-peer <ip>      server data-plane IP (client dials this) (default: $CLIENT_PEER)
  --remote-dir <p>        remote working dir            (default: derived from \$PWD)
  --uet-ref-prov-dir <p>  uet-ref-prov dependency dir   (default: $UET_REF_PROV_DIR)
  --build <mode>          build: clean|make|none        (default: $BUILD)
  --build-only            build both VMs then stop (skip device + test) (default: off)
  --dry-run               print the server/client ssh commands and stop (nothing run)
  --rdma-dev <name>       uprot rdma device name        (default: $RDMA_DEV)
  --reload                force reload of kmod + device (default: off)
  --settle-delay <s>      mutagen settle secs           (default: $SETTLE_DELAY)
  --server-delay <s>      server->client start gap      (default: $SERVER_DELAY)
  --timeout <s>           per-side hard cap on the VMs  (default: $TEST_TIMEOUT)
  -h|--help               show this help and exit

EXAMPLES:
  # Default: incremental build + ensure device + run ibv_ru_pingpong
  run-uet-verbs-test.sh

  # Force a from-scratch rebuild of everything
  run-uet-verbs-test.sh --build clean

  # ibv_ru_rma with the rma_ex test type
  run-uet-verbs-test.sh --app rma --rma-test rma_ex

  # Pingpong with the new post-send WR API and polling (no CQ events)
  run-uet-verbs-test.sh --new-send --no-events

  # Faster iteration: don't rebuild, just rerun the test
  run-uet-verbs-test.sh --build none

  # Force-reload the freshly-built kmod + rdma device before testing
  run-uet-verbs-test.sh --reload

  # Build-only pre-check: compile all stages on both VMs, skip device + test
  run-uet-verbs-test.sh --build-only

  # rma feature flags via the both-sides passthrough
  run-uet-verbs-test.sh --app rma --app-args "-J"                 # job-restricted MR
  run-uet-verbs-test.sh --app rma --app-args "-u 13"             # user-assigned RKey
  run-uet-verbs-test.sh --app rma --app-args "-D"                # derived MR
  run-uet-verbs-test.sh --app rma --app-args "-A"                # job address table

  # pingpong SEND-with-immediate (32b or 64b)
  run-uet-verbs-test.sh --app pingpong --app-args "-I 64"

  # absolute addressing: server and client need DISTINCT JobIDs -> per-side args
  run-uet-verbs-test.sh --app rma \\
      --server-app-args "--absolute --job-id 46" \\
      --client-app-args "--absolute --job-id 47"

APP FLAGS (forward these via --app-args / --server-app-args / --client-app-args):
  ibv_ru_rma:       -p <port> -d <dev> -i <ibport> -s <size> -m <mtu>
                    -r <rxdepth> -n <iters> -e -g <gididx> -c
                    -t <rma|rma_ex|rma_ex64>  -Q(auto-qpn)  -D(derive-mr)
                    -A(addr-table)  -J(job-mr)  -u <rkey>  -b(absolute)  -j <jobid>
  ibv_ru_pingpong:  -p -d -i -s -m -r -n -e -g -c  -N(new-send)  -Q(auto-qpn)
                    -I <32|64>(send-with-immediate)
  (COMMON_ARGS already supplies -d -g -s -n [-e] -c; --rma-test supplies -t; a
   duplicate flag in a passthrough simply overrides, since the apps use getopt.)

EXIT CODES:
  0 = PASS (or build-only build OK)   2 = test FAIL          4 = device setup failure
  1 = build failure                   3 = usage/ssh error
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --app)         APP="$2"; shift 2;;
        --pds)         PDS="$2"; shift 2;;
        --size)        SIZE="$2"; shift 2;;
        --iters)       ITERS="$2"; shift 2;;
        --gid-idx)     GID="$2"; shift 2;;
        --rma-test)    RMA_TEST="$2"; shift 2;;
        --no-events)   EVENTS=0; shift;;
        --new-send)    NEW_SEND=1; shift;;
        --app-args)        EXTRA_APP_ARGS="$2";  shift 2;;
        --server-app-args) SERVER_APP_ARGS="$2"; shift 2;;
        --client-app-args) CLIENT_APP_ARGS="$2"; shift 2;;
        --ifname)      IFNAME="$2"; shift 2;;
        --server-ssh)  SERVER_SSH="$2"; shift 2;;
        --client-ssh)  CLIENT_SSH="$2"; shift 2;;
        --server-peer) SERVER_PEER="$2"; shift 2;;
        --client-peer) CLIENT_PEER="$2"; shift 2;;
        --remote-dir)  REMOTE_DIR="$2"; shift 2;;
        --uet-ref-prov-dir) UET_REF_PROV_DIR="$2"; shift 2;;
        --build)       BUILD="$2"; shift 2;;
        --build-only)  BUILD_ONLY=1; shift;;
        --dry-run)     DRY_RUN=1; shift;;
        --rdma-dev)    RDMA_DEV="$2"; shift 2;;
        --reload)      RELOAD=1; shift;;
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
SETUP_SRV_LOG="$WORKDIR/devsetup-server.log"
SETUP_CLI_LOG="$WORKDIR/devsetup-client.log"
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
    [[ -e "$SETUP_SRV_LOG" ]] && echo "  server devsetup: $SETUP_SRV_LOG"
    [[ -e "$SETUP_CLI_LOG" ]] && echo "  client devsetup: $SETUP_CLI_LOG"
    [[ -e "$SRV_LOG" ]] && echo "  server output: $SRV_LOG"
    [[ -e "$CLI_LOG" ]] && echo "  client output: $CLI_LOG"
}
trap show_logs EXIT

# Line-prefix a stream live, one "[LABEL] line" per input line. Uses awk with
# fflush() because macOS ships BSD sed (no `-u`) and no `stdbuf`, so this is the
# portable way to get unbuffered, line-by-line prefixing as output arrives.
prefix_stream() { awk -v p="$1" '{ print p, $0; fflush() }'; }

# ----------------------------------------------------------------------------
# Test-phase command construction. Each side runs under sudo with the ref-prov
# lib on LD_LIBRARY_PATH and UET_PDS set. Common args (both sides): -d <dev>
# -g <gid> -s <size> -n <iters>, then -e (unless --no-events), then -c (always).
# ibv_ru_rma adds -t <rma-test> on BOTH sides; ibv_ru_pingpong adds -N with
# --new-send. The client additionally dials the server's data-plane IP
# ($CLIENT_PEER); the server takes no host.
# ----------------------------------------------------------------------------
case "$APP" in
    pingpong) TEST_BIN="build/bin/ibv_ru_pingpong";;
    rma)      TEST_BIN="build/bin/ibv_ru_rma";;
    *) echo "ERROR: --app must be pingpong|rma (got '$APP')" >&2; exit 3;;
esac

COMMON_ARGS="-d $RDMA_DEV -g $GID -s $SIZE -n $ITERS"
[[ $EVENTS -eq 1 ]] && COMMON_ARGS+=" -e"
COMMON_ARGS+=" -c"

APP_ARGS=""
if [[ "$APP" == "rma" ]]; then
    APP_ARGS="-t $RMA_TEST"
elif [[ "$APP" == "pingpong" && $NEW_SEND -eq 1 ]]; then
    APP_ARGS="-N"
fi
# Passthrough: --app-args on both sides, then per-side --server/--client-app-args.
[[ -n "$EXTRA_APP_ARGS" ]] && APP_ARGS="${APP_ARGS:+$APP_ARGS }$EXTRA_APP_ARGS"

# Cap each side on the REMOTE (Linux) host, where `timeout` always exists — the
# local wrapper below is absent on macOS. `-k 10` escalates to SIGKILL 10s after
# SIGTERM so a wedged test can't ignore the cap. `timeout` runs under sudo so it
# is the test's direct parent (can signal it); `env` sets the runtime vars.
RUN_PREFIX="sudo timeout -k 10 $TEST_TIMEOUT env LD_LIBRARY_PATH='$REMOTE_DIR/build/lib' UET_PDS='$PDS'"
SERVER_CMD="$RUN_PREFIX $TEST_BIN $COMMON_ARGS${APP_ARGS:+ $APP_ARGS}${SERVER_APP_ARGS:+ $SERVER_APP_ARGS}"
CLIENT_CMD="$RUN_PREFIX $TEST_BIN $COMMON_ARGS${APP_ARGS:+ $APP_ARGS}${CLIENT_APP_ARGS:+ $CLIENT_APP_ARGS} $CLIENT_PEER"

# Three-stage build command, run per VM (each stage cd's to its own dir).
# Each stage only runs if the previous one succeeds ('&&'):
#   stage 1: build the uet-ref-prov dependency
#   stage 2: build the RDMA apps, pointing at the ref-prov via UET_REF_PROV_PATH
#   stage 3: build the uprot kernel module (kmod) that enables rdma device
#            discovery/open
# 'clean' also wipes the RDMA build/ dir so ./build.sh reconfigures from scratch.
REFPROV_BUILD_STAGE="cd '$UET_REF_PROV_DIR'"
RDMA_BUILD_STAGE="cd '$REMOTE_DIR'"
KMOD_BUILD_STAGE="cd '$REMOTE_DIR/providers/uprot/kmod'"
case "$BUILD" in
    clean)
        REFPROV_BUILD_STAGE+=" && make clean && make"
        RDMA_BUILD_STAGE+=" && rm -rf build && UET_REF_PROV_PATH='$UET_REF_PROV_DIR' ./build.sh"
        KMOD_BUILD_STAGE+=" && make clean && make"
        ;;
    make)
        REFPROV_BUILD_STAGE+=" && make"
        RDMA_BUILD_STAGE+=" && UET_REF_PROV_PATH='$UET_REF_PROV_DIR' ./build.sh"
        KMOD_BUILD_STAGE+=" && make"
        ;;
    none)
        ;;
    *) echo "ERROR: --build must be clean|make|none (got '$BUILD')" >&2; exit 3;;
esac

if [[ "$BUILD" == "none" ]]; then
    BUILD_CMD=""
else
    BUILD_CMD="$REFPROV_BUILD_STAGE && $RDMA_BUILD_STAGE && $KMOD_BUILD_STAGE"
fi

if [[ $BUILD_ONLY -eq 1 && "$BUILD" == "none" ]]; then
    echo "ERROR: --build-only with --build none has nothing to do." >&2
    exit 3
fi

# ----------------------------------------------------------------------------
# Device-setup command, run per VM after the build. Default is "ensure present"
# (load kmod / create rdma device only if missing). With RELOAD=1 it first tears
# down (rdma link delete + rmmod) so the freshly-built module gets loaded. Ends
# by verifying the kmod is loaded and `ibv_devices` lists the uprot device;
# exits nonzero (fails the run) if not.
DEVICE_CMD=$(cat <<EOF
set -u
mod_loaded() { lsmod | grep -q '^${KMOD_NAME}[[:space:]]'; }
dev_exists() { sudo LD_LIBRARY_PATH='${REMOTE_DIR}/build/lib' '${REMOTE_DIR}/build/bin/ibv_devices' 2>/dev/null | grep -qw '${RDMA_DEV}'; }

if [ ${RELOAD} -eq 1 ]; then
    echo '--> [reload] tearing down existing uprot device/module...'
    if dev_exists; then echo '    rdma link delete ${RDMA_DEV}'; sudo rdma link delete '${RDMA_DEV}' || true; fi
    if mod_loaded; then echo '    rmmod ${KMOD_NAME}'; sudo rmmod '${KMOD_NAME}'; fi
fi

if mod_loaded; then
    echo '--> kmod ${KMOD_NAME} already loaded'
else
    echo '--> insmod ${KMOD_KO}'
    cd '${REMOTE_DIR}/providers/uprot/kmod' && sudo insmod '${KMOD_KO}'
fi

if dev_exists; then
    echo '--> rdma device ${RDMA_DEV} already present'
else
    echo '--> rdma link add ${RDMA_DEV} (netdev ${IFNAME})'
    sudo rdma link add '${RDMA_DEV}' type uprot netdev '${IFNAME}'
fi

mod_loaded || { echo 'ERROR: kmod ${KMOD_NAME} not loaded after setup'; exit 1; }
dev_exists || { echo 'ERROR: rdma device ${RDMA_DEV} not present after setup (ibv_devices)'; exit 1; }
echo '--> device setup OK (${RDMA_DEV})'
EOF
)

echo "=============================================================="
echo " uet rdma test run"
echo "   remote dir : $REMOTE_DIR"
echo "   ref-prov   : $UET_REF_PROV_DIR"
echo "   build      : ${BUILD}$([[ $BUILD_ONLY -eq 1 ]] && echo '   (build-only: device + test skipped)')"
echo "   rdma dev   : ${RDMA_DEV}   reload: $([[ $RELOAD -eq 1 ]] && echo yes || echo no)"
echo "   app        : ${APP}   UET_PDS: ${PDS}   ifname: ${IFNAME}"
echo "   test args  : ${COMMON_ARGS}${APP_ARGS:+ $APP_ARGS}   (client dials ${CLIENT_PEER})"
[[ -n "$SERVER_APP_ARGS" ]] && echo "   server args: +${SERVER_APP_ARGS}"
[[ -n "$CLIENT_APP_ARGS" ]] && echo "   client args: +${CLIENT_APP_ARGS}"
echo "   server     : $SERVER_SSH   (peer $SERVER_PEER)"
echo "   client     : $CLIENT_SSH   (peer $CLIENT_PEER)"
echo "=============================================================="

# --dry-run: print the exact server/client commands (copy/paste-able) and stop.
# Nothing is synced, built, or run.
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
if [[ -n "$BUILD_CMD" ]]; then
    echo "--> Building on server and client (uet-ref-prov + RDMA apps, ${BUILD})..."
    ssh "${SSH_OPTS[@]}" "$SERVER_SSH" "$BUILD_CMD" >"$BUILD_SRV_LOG" 2>&1 &
    bs_pid=$!
    ssh "${SSH_OPTS[@]}" "$CLIENT_SSH" "$BUILD_CMD" >"$BUILD_CLI_LOG" 2>&1 &
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
# 2b. Build-only pre-check: stop here (build succeeded) before device setup and
#     the test.
# ----------------------------------------------------------------------------
if [[ $BUILD_ONLY -eq 1 ]]; then
    echo
    echo "############################################################"
    echo "#  RESULT: BUILD OK  (--build-only; device setup + test skipped)"
    echo "############################################################"
    exit 0
fi

# ----------------------------------------------------------------------------
# 3. Ensure the uprot rdma device on both VMs in parallel (load kmod + create
#    the rdma link; --reload forces a teardown+recreate first).
# ----------------------------------------------------------------------------
if [[ $RELOAD -eq 1 ]]; then
    echo "--> Setting up uprot device on server and client (reload)..."
else
    echo "--> Ensuring uprot device on server and client..."
fi
ssh "${SSH_OPTS[@]}" "$SERVER_SSH" "$DEVICE_CMD" >"$SETUP_SRV_LOG" 2>&1 &
ds_pid=$!
ssh "${SSH_OPTS[@]}" "$CLIENT_SSH" "$DEVICE_CMD" >"$SETUP_CLI_LOG" 2>&1 &
dc_pid=$!

wait "$ds_pid"; ds_rc=$?
wait "$dc_pid"; dc_rc=$?

if [[ $ds_rc -ne 0 || $dc_rc -ne 0 ]]; then
    echo
    echo "ERROR: uprot device setup failed (server rc=$ds_rc, client rc=$dc_rc)."
    echo "----- SERVER device-setup output ------------------------------"
    cat "$SETUP_SRV_LOG"
    echo "----- CLIENT device-setup output ------------------------------"
    cat "$SETUP_CLI_LOG"
    exit 4
fi
# Show what each side did (which lines are prefixed with '-->').
sed 's/^/[SRV setup] /' "$SETUP_SRV_LOG"
sed 's/^/[CLI setup] /' "$SETUP_CLI_LOG"
echo "--> uprot device ready on both VMs."

# ----------------------------------------------------------------------------
# 4. Start the server test in the background.
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
# 5. Short delay, then run the client test (foreground).
# ----------------------------------------------------------------------------
echo "--> Waiting ${SERVER_DELAY}s for server to come up..."
sleep "$SERVER_DELAY"

echo "--> Starting CLIENT test..."
"${TIMEOUT_CMD[@]}" ssh "${SSH_OPTS[@]}" "$CLIENT_SSH" \
    "cd '$REMOTE_DIR' && $CLIENT_CMD" 2>&1 \
    | tee "$CLI_LOG" | prefix_stream "[CLI]"
cli_rc="${PIPESTATUS[0]}"

# ----------------------------------------------------------------------------
# 6. Wait for server (it exits on its own once the client completes).
# ----------------------------------------------------------------------------
echo "--> Client finished (rc=$cli_rc); waiting for server to exit..."
wait "$srv_pid"; srv_rc=$?

if [[ $cli_rc -eq 124 || $srv_rc -eq 124 ]]; then
    echo "WARNING: a side hit the ${TEST_TIMEOUT}s timeout (client_rc=$cli_rc server_rc=$srv_rc)."
fi

# ----------------------------------------------------------------------------
# Evaluate result. PASS iff BOTH the client and server processes exit 0. With -c
# always on, a data-validation mismatch makes the binary exit nonzero.
# ----------------------------------------------------------------------------
echo
if [[ $cli_rc -eq 0 && $srv_rc -eq 0 ]]; then
    echo "############################################################"
    echo "#  RESULT: PASS  (client_rc=0 server_rc=0)"
    echo "############################################################"
    echo "----- CLIENT output (tail) ------------------------------------"
    tail -n 20 "$CLI_LOG"
    echo "----- SERVER output (tail) ------------------------------------"
    tail -n 20 "$SRV_LOG"
    exit 0
else
    echo "############################################################"
    echo "#  RESULT: FAIL  (client_rc=$cli_rc server_rc=$srv_rc)"
    echo "############################################################"
    echo
    echo "================ FULL CLIENT OUTPUT ==========================="
    cat "$CLI_LOG"
    echo
    echo "================ FULL SERVER OUTPUT ==========================="
    cat "$SRV_LOG"
    exit 2
fi
