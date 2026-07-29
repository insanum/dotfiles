#!/usr/bin/env bash
# uet-matrix — run the UET test matrix across two suites and both address
# families, or a selected subset:
#
#   verbs   : ibv_ru_rma / ibv_ru_pingpong via the uet-verbs-test harness
#             (rdma-core uprot provider). IPv4 = GID 1, IPv6 link-local = GID 0.
#   refprov : ./scripts/uet_test.sh via the uet-test harness (the uet-ref-prov
#             standalone ./uet app). One cell per PDS/security mode, each running
#             all test types (test=all), shim=rawsock.
#
# Both suites sweep IPv4 and IPv6. The IPv6 link-local peers are discovered
# dynamically from the interface each VM's data-plane IPv4 is bound to -- nothing
# is hardcoded.
set -u

# ---- harnesses + remote dirs ------------------------------------------------
HARNESS_V="${UET_RDMA_HARNESS:-$HOME/.claude/skills/uet-verbs-test/run-uet-verbs-test.sh}"
HARNESS_RP="${UET_REFPROV_HARNESS:-$HOME/.claude/skills/uet-test/run-uet-test.sh}"
RD_V="${UET_REMOTE_DIR:-/home/edavis/sync/uec/uet-rdma-core.fork/wt_uet}"
RD_RP="${UET_REFPROV_DIR:-/home/edavis/sync/uec/uet-ref-prov.fork/wt_pds}"
OUT="${UET_MATRIX_OUT:-/tmp/uet_matrix}"

# GID indices per the uprot kmod (see ibv_devinfo): 0 = IPv6 link-local,
# 1 = IPv4-mapped. (verbs suite only)
GID_V4=1
GID_V6=0
SHIM="${UET_SHIM:-rawsock}"          # refprov NIC shim
IFNAME="${UET_IFNAME:-enp10s0}"      # refprov interface name on the VMs

# VM ssh targets (for IPv6 link-local discovery of each side's data-plane iface)
SERVER_SSH="${UET_SERVER_SSH:-edavis@172.16.71.42}"
CLIENT_SSH="${UET_CLIENT_SSH:-edavis@172.16.71.13}"
DP_SUBNET="${UET_DP_SUBNET:-192.168.224}"

# defaults
ITERS=10
CFG_TIMEOUT=90                          # verbs: per-side cap for one client/server run
RP_TIMEOUT="${UET_RP_TIMEOUT:-900}"     # refprov: cap for a whole test=all cell (much longer)
BUILD=clean          # first-cell-per-suite build mode (clean|make|none); rest: none
FAMILY=both          # v4 | v6 | both
SUITE=both           # verbs | refprov | both
MODE=run             # run | list | debug
declare -a SELECTORS=()

# ---- verbs cells: label+desc :: app :: rma-subtest :: common :: server :: client
VERBS_CONFIGS=(
  "R01 rma_ex64 app-spec SYMMETRIC {51,2}      :: rma :: rma_ex64 :: --pidonfep 51 --ri 2 ::  :: "
  "R02 rma_ex64 app-spec ASYMMETRIC 42/1|51/2  :: rma :: rma_ex64 ::  :: --pidonfep 42 --ri 1 :: --pidonfep 51 --ri 2"
  "R03 rma_ex64 provider-assigned -Q           :: rma :: rma_ex64 :: -Q ::  :: "
  "R04 rma_ex64 ABSOLUTE -b ASYMMETRIC         :: rma :: rma_ex64 :: -b :: --pidonfep 42 --ri 1 :: --pidonfep 51 --ri 2"
  "R05 rma_ex64 derived-MR -D ASYMMETRIC       :: rma :: rma_ex64 :: -D :: --pidonfep 42 --ri 1 :: --pidonfep 51 --ri 2"
  "R06 rma_ex64 addr-table -A SYMMETRIC        :: rma :: rma_ex64 :: -A --pidonfep 51 --ri 2 ::  :: "
  "R07 rma_ex64 job-MR -J SYMMETRIC            :: rma :: rma_ex64 :: -J --pidonfep 51 --ri 2 ::  :: "
  "R08 rma_ex64 user-rkey -u SYMMETRIC         :: rma :: rma_ex64 :: -u 0x1234 --pidonfep 51 --ri 2 ::  :: "
  "R09 rma_ex   app-spec SYMMETRIC             :: rma :: rma_ex   :: --pidonfep 51 --ri 2 ::  :: "
  "R10 rma      legacy-32b SYMMETRIC           :: rma :: rma      :: --pidonfep 51 --ri 2 ::  :: "
  "R11 rma_ex64 multi-SGE -S 4 (RMA S/G)       :: rma :: rma_ex64 :: -S 4 --pidonfep 51 --ri 2 ::  :: "
  "R12 rma      legacy multi-SGE -S 4          :: rma :: rma      :: -S 4 --pidonfep 51 --ri 2 ::  :: "
  "P01 pingpong app-spec SYMMETRIC {51,2}      :: pingpong :: - :: --pidonfep 51 --ri 2 ::  :: "
  "P02 pingpong app-spec ASYMMETRIC 42/1|51/2  :: pingpong :: - ::  :: --pidonfep 42 --ri 1 :: --pidonfep 51 --ri 2"
  "P03 pingpong provider-assigned -Q           :: pingpong :: - :: -Q ::  :: "
  "P04 pingpong imm64 -I 64 SYMMETRIC          :: pingpong :: - :: -I 64 --pidonfep 51 --ri 2 ::  :: "
  "P05 pingpong imm32 -I 32 SYMMETRIC          :: pingpong :: - :: -I 32 --pidonfep 51 --ri 2 ::  :: "
  "P06 pingpong multi-SGE -S 4 (legacy)        :: pingpong :: - :: -S 4 --pidonfep 51 --ri 2 ::  :: "
  "P07 pingpong multi-SGE -N -S 4 (builder)    :: pingpong :: - :: -N -S 4 --pidonfep 51 --ri 2 ::  :: "
  "P08 pingpong imm64 + multi-SGE -I 64 -S 4   :: pingpong :: - :: -I 64 -S 4 --pidonfep 51 --ri 2 ::  :: "
  "P09 pingpong imm32 + multi-SGE -I 32 -S 4   :: pingpong :: - :: -I 32 -S 4 --pidonfep 51 --ri 2 ::  :: "
)

# ---- refprov cells: one per PDS/security mode (test=all). "<pds-mode> <desc>"
# NOTE: test=all on a pds-capable backend also runs a forced-RUDI rma pass and
# a forced-UUD datagram pass (uet_test.sh rudi_pass / uud_pass), so every pds*
# cell below exercises RUDI and UUD too. The sng cell does not (both need the
# reliable pds engine).
REFPROV_CONFIGS=(
  "sng             single-packet PDS (no reliability)"
  "pds             reliable PDS (RUD/ROD + RUDI + UUD), no security"
  "pds_direct      TSS security: direct mode (+RUDI +UUD)"
  "pds_cluster     TSS security: cluster mode (+RUDI +UUD)"
  "pds_cluster_ssi TSS security: cluster mode + SSI (+RUDI +UUD)"
  "pds_server_ssi  TSS security: server mode + SSI (+RUDI +UUD)"
)

usage() {
  cat <<EOF
uet-matrix — run the UET test matrix over two suites and both address families.

USAGE
  run-uet-matrix.sh [options] [TEST ...]

  (no TEST)          run every cell in the selected suite(s)/family(ies)
  TEST ...           run only matching cells. A TEST matches a cell's base label
                     (R01, pds_direct), its family:label (v6:R01), a family (v6),
                     or a suite (verbs, refprov). Quoted globs work: 'R*',
                     'P0[1-4]', 'pds_*', 'v6:*'.

OPTIONS
  -s, --suite <s>        verbs | refprov | both     (default: both)
  -f, --family <fam>     v4 | v6 | both             (default: both)
  -l, --list             list all available tests and exit
  -d, --debug            print the exact command lines (markdown) for the
                         selected tests and exit — nothing is built or run
  -b, --build <mode>     clean | make | none — build mode for the FIRST cell of
                         each suite; later cells reuse the binaries. (default: clean)
  -n, --iters <n>        verbs iterations per test  (default: $ITERS)
  -t, --timeout <s>      verbs per-side hard cap seconds (default: $CFG_TIMEOUT). Each
                         refprov cell runs test=all and uses its own cap
                         (\$UET_RP_TIMEOUT, default $RP_TIMEOUT).
  -h, --help             this help

SUITES
  verbs    ibv_ru_rma / ibv_ru_pingpong (uprot provider). IPv4 = -g $GID_V4,
           IPv6 = -g $GID_V6 dialing the server's link-local.
  refprov  ./scripts/uet_test.sh (ref-prov ./uet). One cell per PDS mode,
           test=all, shim=$SHIM. test=all on a pds* backend also runs a
           forced-RUDI rma pass and a forced-UUD datagram pass (not on sng).
           Each side dials the other's data-plane address (link-local for IPv6).

EXAMPLES
  run-uet-matrix.sh                     # full sweep: both suites, v4 + v6
  run-uet-matrix.sh --list              # catalog
  run-uet-matrix.sh -s refprov          # just the ref-prov suite (v4 + v6)
  run-uet-matrix.sh -s verbs -f v6 R11  # one verbs cell, IPv6
  run-uet-matrix.sh pds_server_ssi      # the TSS server-mode ref-prov cell (both fams)
  run-uet-matrix.sh -d -s refprov       # print ref-prov commands, run nothing
EOF
}

# ---- arg parse --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--suite)   SUITE="${2:-}"; shift 2;;
    -f|--family)  FAMILY="${2:-}"; shift 2;;
    -l|--list)    MODE=list; shift;;
    -d|--debug)   MODE=debug; shift;;
    -b|--build)   BUILD="${2:-}"; shift 2;;
    -n|--iters)   ITERS="${2:-}"; shift 2;;
    -t|--timeout) CFG_TIMEOUT="${2:-}"; shift 2;;
    -h|--help)    usage; exit 0;;
    --)           shift; while [[ $# -gt 0 ]]; do SELECTORS+=("$1"); shift; done;;
    -*)           echo "unknown option: $1" >&2; usage >&2; exit 2;;
    *)            SELECTORS+=("$1"); shift;;
  esac
done

case "$SUITE" in
  verbs)   SUITES=(verbs);;
  refprov) SUITES=(refprov);;
  both)    SUITES=(verbs refprov);;
  *)       echo "bad --suite '$SUITE' (want verbs|refprov|both)" >&2; exit 2;;
esac
case "$FAMILY" in
  v4)   FAMS=(v4);;
  v6)   FAMS=(v6);;
  both) FAMS=(v4 v6);;
  *)    echo "bad --family '$FAMILY' (want v4|v6|both)" >&2; exit 2;;
esac

# verbs "R01 desc..." -> base + description
cfg_base() { awk -F' :: ' '{print $1}' <<<"$1" | awk '{print $1}'; }
cfg_desc() { awk -F' :: ' '{print $1}' <<<"$1" | sed -E 's/^[[:space:]]*[A-Za-z][0-9]+[[:space:]]+//; s/[[:space:]]+$//'; }

# render an argv for display: single-quote any element containing whitespace.
disp_args() {
  local out="" a
  for a in "$@"; do
    if [[ "$a" == *[[:space:]]* ]]; then out+=" '$a'"; else out+=" $a"; fi
  done
  printf '%s' "${out# }"
}

# does (suite,fam,base) match the user's selectors?  (no selectors => all)
cell_selected() {
  local suite="$1" fam="$2" base="$3" full="$2:$3" s
  [[ ${#SELECTORS[@]} -eq 0 ]] && return 0
  for s in "${SELECTORS[@]}"; do
    [[ "$base" == $s || "$full" == $s || "$fam" == $s || "$suite" == $s ]] && return 0
  done
  return 1
}

# ---- list mode --------------------------------------------------------------
if [[ "$MODE" == list ]]; then
  echo "UET matrix — available tests"
  echo "  suites: ${SUITES[*]}    families: ${FAMS[*]}"
  if printf '%s\n' "${SUITES[@]}" | grep -qx verbs; then
    echo
    echo "verbs  (ibv_ru_rma / ibv_ru_pingpong; IPv4=-g $GID_V4, IPv6=-g $GID_V6):"
    for entry in "${VERBS_CONFIGS[@]}"; do
      printf "  %-6s  %s\n" "$(cfg_base "$entry")" "$(cfg_desc "$entry")"
    done
  fi
  if printf '%s\n' "${SUITES[@]}" | grep -qx refprov; then
    echo
    echo "refprov  (uet_test.sh, test=all, shim=$SHIM; one cell per PDS mode):"
    for entry in "${REFPROV_CONFIGS[@]}"; do
      printf "  %-16s  %s\n" "${entry%% *}" "$(sed -E 's/^[^ ]+[[:space:]]+//' <<<"$entry")"
    done
  fi
  echo
  echo "Each runs per selected family (labels v4:<id> / v6:<id>). Select by base"
  echo "label (R01, pds_direct), family:label (v6:R01), a family (v6), a suite"
  echo "(refprov), or a quoted glob ('R*', 'pds_*'). No selector runs everything."
  exit 0
fi

# ---- IPv6 link-local discovery (per side; only when v6 cells are in play) ----
discover_ll() {  # $1 = ssh target ; prints "<iface> <linklocal>"
  ssh -o ConnectTimeout=10 "$1" "
    iface=\$(ip -o -4 addr show | awk '/inet ${DP_SUBNET}\\./{print \$2; exit}')
    ll=\$(ip -o -6 addr show dev \"\$iface\" scope link | awk '{print \$4}' | head -1 | cut -d/ -f1)
    echo \"\$iface \$ll\"
  " 2>/dev/null
}

SERVER_V6="" ; CLIENT_V6=""
if printf '%s\n' "${FAMS[@]}" | grep -qx v6; then
  read -r _SIF SERVER_V6 < <(discover_ll "$SERVER_SSH")
  if [[ -z "${SERVER_V6:-}" ]]; then
    echo "WARNING: no server link-local IPv6 discovered -- dropping IPv6 cells" >&2
    FAMS=( $(printf '%s\n' "${FAMS[@]}" | grep -vx v6) )
  else
    echo "IPv6 server peer: $SERVER_V6 ($_SIF via $SERVER_SSH)" >&2
    # the ref-prov suite also needs the client's link-local (each side dials the other)
    if printf '%s\n' "${SUITES[@]}" | grep -qx refprov; then
      read -r _CIF CLIENT_V6 < <(discover_ll "$CLIENT_SSH")
      if [[ -n "${CLIENT_V6:-}" ]]; then
        echo "IPv6 client peer: $CLIENT_V6 ($_CIF via $CLIENT_SSH)" >&2
      else
        echo "WARNING: no client link-local IPv6 discovered -- IPv6 ref-prov cells skipped" >&2
      fi
    fi
  fi
fi

# ---- run / debug ------------------------------------------------------------
[[ "$MODE" == run ]] && { mkdir -p "$OUT"; : > "$OUT/summary.txt"; }
if [[ "$MODE" == debug ]]; then
  echo "# UET matrix — exact commands"
  echo
  echo "verbs: IPv4 \`-g $GID_V4\`, IPv6 \`-g $GID_V6\`. refprov: \`uet_test.sh\`, shim \`$SHIM\`."
  [[ -n "${SERVER_V6:-}" ]] && echo "IPv6 server peer \`$SERVER_V6\`${CLIENT_V6:+, client peer \`$CLIENT_V6\`}."
  echo
fi

declare -A SUITE_FIRST=([verbs]=1 [refprov]=1)
declare -a RESULTS
i=0

# emit one cell: caller sets the global HARGS array (harness args, no --build).
emit_cell() {  # $1=suite $2=fam $3=base $4=desc $5=harness
  local suite="$1" fam="$2" base="$3" desc="$4" harness="$5"
  local label="$fam:$base"
  i=$((i+1))

  local bmode
  if [[ "$MODE" == debug ]]; then bmode=none
  elif [[ ${SUITE_FIRST[$suite]} -eq 1 ]]; then bmode="$BUILD"; SUITE_FIRST[$suite]=0
  else bmode=none; fi
  local -a A=( --build "$bmode" "${HARGS[@]}" )

  if [[ "$MODE" == debug ]]; then
    local dry srv_t cli_t srv_c cli_c
    dry=$("$harness" --dry-run "${A[@]}" 2>/dev/null)
    srv_t=$(sed -nE 's/^# server \((.*)\):$/\1/p' <<<"$dry")
    cli_t=$(sed -nE 's/^# client \((.*)\):$/\1/p' <<<"$dry")
    srv_c=$(grep -E '^ssh ' <<<"$dry" | sed -n 1p)
    cli_c=$(grep -E '^ssh ' <<<"$dry" | sed -n 2p)
    printf '## %s — %s\n\n' "$label" "$desc"
    printf 'Harness (re-run just this cell via the skill):\n\n```sh\n%s %s\n```\n\n' \
           "$harness" "$(disp_args "${A[@]}")"
    printf 'Server (`%s`):\n\n```sh\n%s\n```\n\n' "$srv_t" "$srv_c"
    printf 'Client (`%s`):\n\n```sh\n%s\n```\n\n' "$cli_t" "$cli_c"
    return
  fi

  local logf rc res
  logf="$OUT/$(printf '%03d' "$i")-${label//:/_}.log"
  echo "===== [$label] $desc  (build=$bmode) =====" | tee -a "$OUT/summary.txt"
  "$harness" "${A[@]}" > "$logf" 2>&1
  rc=$?
  res=$(grep -aoE "RESULT: (PASS|FAIL)" "$logf" | tail -1)
  [[ -z "$res" ]] && res="RESULT: ??? (harness rc=$rc)"
  RESULTS+=("$(printf '%-22s %s' "$label" "$res")")
  echo "  -> $res (rc=$rc)   [log: $logf]" | tee -a "$OUT/summary.txt"
}

for suite in "${SUITES[@]}"; do
  for fam in "${FAMS[@]}"; do
    if [[ "$suite" == verbs ]]; then
      for entry in "${VERBS_CONFIGS[@]}"; do
        base=$(cfg_base "$entry")
        cell_selected verbs "$fam" "$base" || continue
        desc=$(cfg_desc "$entry")
        app=$(awk -F' :: ' '{print $2}' <<<"$entry" | tr -d ' ')
        rmatest=$(awk -F' :: ' '{print $3}' <<<"$entry" | tr -d ' ')
        common=$(awk -F' :: ' '{print $4}' <<<"$entry")
        srv=$(awk -F' :: ' '{print $5}' <<<"$entry")
        cli=$(awk -F' :: ' '{print $6}' <<<"$entry")
        HARGS=( --remote-dir "$RD_V" --app "$app" --iters "$ITERS" --timeout "$CFG_TIMEOUT" )
        if [[ "$fam" == v6 ]]; then HARGS+=( --gid-idx "$GID_V6" --client-peer "$SERVER_V6" )
        else                       HARGS+=( --gid-idx "$GID_V4" ); fi
        [[ "$app" == "rma" && "$rmatest" != "-" ]] && HARGS+=( --rma-test "$rmatest" )
        [[ -n "${common// }" ]] && HARGS+=( --app-args "$common" )
        [[ -n "${srv// }" ]] && HARGS+=( --server-app-args "$srv" )
        [[ -n "${cli// }" ]] && HARGS+=( --client-app-args "$cli" )
        emit_cell verbs "$fam" "$base" "$desc" "$HARNESS_V"
      done
    else  # refprov
      for entry in "${REFPROV_CONFIGS[@]}"; do
        base="${entry%% *}"
        cell_selected refprov "$fam" "$base" || continue
        # IPv6 ref-prov needs the client's link-local; skip if not discovered
        if [[ "$fam" == v6 && -z "${CLIENT_V6:-}" ]]; then continue; fi
        desc=$(sed -E 's/^[^ ]+[[:space:]]+//' <<<"$entry")
        HARGS=( --remote-dir "$RD_RP" --test all --pds "$base" --shim "$SHIM" \
                --ifname "$IFNAME" --timeout "$RP_TIMEOUT" )
        if [[ "$fam" == v6 ]]; then
          # server dials the client's addr, client dials the server's addr
          HARGS+=( --server-peer "$CLIENT_V6" --client-peer "$SERVER_V6" )
        fi   # v4: use the uet-test skill's default data-plane peers
        emit_cell refprov "$fam" "$base" "$desc" "$HARNESS_RP"
      done
    fi
  done
done

if [[ $i -eq 0 ]]; then
  echo "no tests matched: ${SELECTORS[*]:-<all>} (suite $SUITE, family $FAMILY)" >&2
  exit 2
fi

[[ "$MODE" == debug ]] && exit 0

# ---- summary (run mode) -----------------------------------------------------
echo ""                                     | tee -a "$OUT/summary.txt"
echo "========== MATRIX SUMMARY =========="  | tee -a "$OUT/summary.txt"
for r in "${RESULTS[@]}"; do echo "$r"       | tee -a "$OUT/summary.txt"; done
pass=$(printf '%s\n' "${RESULTS[@]}" | grep -c "PASS")
echo "------------------------------------"  | tee -a "$OUT/summary.txt"
echo "TOTAL: $pass/${#RESULTS[@]} PASS"       | tee -a "$OUT/summary.txt"
[[ "$pass" -eq "${#RESULTS[@]}" ]]
