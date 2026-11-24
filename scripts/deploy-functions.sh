#!/usr/bin/env bash
# Deploys Cloud Functions in batches, so a deploy stays under Cloud Run's
# regional CPU quota (asia-south1: 20 vCPU, the default; an increase was
# refused for lack of usage history, Nov 2026).
#
# Why: every updated function starts a new instance for its health check
# and Cloud Run keeps it idle for ~15 min. All ~155 functions at once peak
# at ~26 vCPU ("Quota exceeded for total allowable CPU per project per
# region"). Batches of ~40, each started only once the running instance
# count is low again, peak well under 20.
#
# Usage (from the repo root; deploy from an up-to-date Development):
#   bash scripts/deploy-functions.sh                 # every exported function
#   bash scripts/deploy-functions.sh fnA fnB ...     # only these
#   bash scripts/deploy-functions.sh --dry-run       # print the batches
# Options: --batch N (default 40), --project ID (default zippy-app-2024),
#          --max-instances N (wait until at most N instances run; default 45)
#
# Waiting reads Cloud Monitoring (read-only) with your gcloud login. Without
# gcloud it waits a fixed 15 minutes between batches instead.
#
# Never deletes anything: a function removed from the code must be deleted
# with `firebase functions:delete <name> --region asia-south1`. Rules and
# indexes are separate: `firebase deploy --only firestore:rules,firestore:indexes`.
set -u
cd "$(dirname "$0")/.."

PROJECT=zippy-app-2024
REGION=asia-south1
BATCH=40
MAX_INSTANCES=45
DRY_RUN=0
POLL_SECONDS=60
MAX_WAIT_SECONDS=1800
FIXED_WAIT_SECONDS=900
NAMES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --batch) BATCH="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --max-instances) MAX_INSTANCES="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    -*) echo "Unknown option $1" >&2; exit 2 ;;
    *) NAMES+=("$1"); shift ;;
  esac
done

# Every function exported from functions/src/index.ts ("export { a, b } from"
# and "export const x"), unless names were given.
if [ ${#NAMES[@]} -eq 0 ]; then
  while IFS= read -r n; do NAMES+=("$n"); done < <(node -e '
    const s = require("fs").readFileSync("functions/src/index.ts", "utf8");
    const out = new Set();
    for (const m of s.matchAll(/export\s*\{([^}]*)\}\s*from/g))
      for (const p of m[1].split(",")) {
        const t = p.trim();
        if (t) out.add(t.split(/\s+as\s+/).pop().trim());
      }
    for (const m of s.matchAll(/export\s+const\s+(\w+)/g)) out.add(m[1]);
    console.log([...out].join("\n"));
  ')
fi
[ ${#NAMES[@]} -gt 0 ] || { echo "No functions found." >&2; exit 1; }

# Running Cloud Run instances in the region (all services, active + idle):
# the highest count in the last 5 minutes, or "" if it can't be read.
running_instances() {
  command -v gcloud >/dev/null 2>&1 || return 0
  local token
  token=$(gcloud auth print-access-token 2>/dev/null) || return 0
  local start end
  start=$(node -e 'console.log(new Date(Date.now() - 5 * 60e3).toISOString())')
  end=$(node -e 'console.log(new Date().toISOString())')
  curl -s -G -H "Authorization: Bearer $token" \
    "https://monitoring.googleapis.com/v3/projects/$PROJECT/timeSeries" \
    --data-urlencode "filter=metric.type=\"run.googleapis.com/container/instance_count\" AND resource.labels.location=\"$REGION\"" \
    --data-urlencode "interval.startTime=$start" \
    --data-urlencode "interval.endTime=$end" \
    --data-urlencode "aggregation.alignmentPeriod=60s" \
    --data-urlencode "aggregation.perSeriesAligner=ALIGN_MAX" \
    --data-urlencode "aggregation.crossSeriesReducer=REDUCE_SUM" |
    node -e '
      let s = ""; process.stdin.on("data", (d) => (s += d)).on("end", () => {
        try {
          const j = JSON.parse(s);
          if (j.error) return;
          const pts = (j.timeSeries || []).flatMap((t) => t.points || []);
          // Metrics arrive a few minutes late: use the highest recent value.
          console.log(pts.length ? Math.max(...pts.map((p) => Number(p.value.int64Value || 0))) : 0);
        } catch {}
      });'
}

wait_for_headroom() {
  local waited=0 n
  while :; do
    n=$(running_instances)
    if [ -z "$n" ]; then
      echo "   (can't read Cloud Monitoring; waiting a fixed $((FIXED_WAIT_SECONDS / 60)) min)"
      sleep "$FIXED_WAIT_SECONDS"
      return
    fi
    if [ "$n" -le "$MAX_INSTANCES" ]; then
      echo "   $n instances running: go"
      return
    fi
    if [ "$waited" -ge "$MAX_WAIT_SECONDS" ]; then
      echo "   still $n instances after $((waited / 60)) min: going anyway"
      return
    fi
    echo "   $n instances running (want <= $MAX_INSTANCES), waiting…"
    sleep "$POLL_SECONDS"
    waited=$((waited + POLL_SECONDS))
  done
}

# Deploys the given functions; prints the names that failed.
deploy_batch() {
  local only="" f log
  for f in "$@"; do only="$only${only:+,}functions:$f"; done
  local code names
  log=$(mktemp)
  firebase deploy --only "$only" --project "$PROJECT" 2>&1 | tee "$log" >&2
  code=${PIPESTATUS[0]}
  # "Functions deploy had errors with the following functions:\n    name(region)"
  # The names are indented with a tab (or spaces); the list ends at the
  # first line that isn't indented.
  names=$(sed -n '/had errors with the following functions/,/^[^[:space:]]/p' "$log" |
    sed -n 's/^[[:space:]][[:space:]]*\([A-Za-z0-9_-]*\)(.*/\1/p')
  rm -f "$log"
  if [ -n "$names" ]; then
    echo "$names"
  elif [ "$code" -ne 0 ]; then
    # Failed before deploying anything (build, auth…): the whole batch.
    printf '%s\n' "$@"
  fi
}

total=${#NAMES[@]}
batches=$(((total + BATCH - 1) / BATCH))
echo "== $total functions in $batches batch(es) of up to $BATCH → $PROJECT ($REGION)"

if [ "$DRY_RUN" = 1 ]; then
  i=0
  while [ $i -lt "$total" ]; do
    echo "-- batch $((i / BATCH + 1)): ${NAMES[*]:$i:$BATCH}"
    i=$((i + BATCH))
  done
  exit 0
fi

failed=()
i=0
while [ $i -lt "$total" ]; do
  batch=("${NAMES[@]:$i:$BATCH}")
  echo
  echo "== Batch $((i / BATCH + 1))/$batches (${#batch[@]} functions)"
  wait_for_headroom
  while IFS= read -r f; do [ -n "$f" ] && failed+=("$f"); done < <(deploy_batch "${batch[@]}")
  i=$((i + BATCH))
done

# Two more rounds for anything that failed (usually the quota, briefly).
for round in 1 2; do
  [ ${#failed[@]} -eq 0 ] && break
  echo
  echo "== Retry $round: ${failed[*]}"
  wait_for_headroom
  retry=("${failed[@]}")
  failed=()
  while IFS= read -r f; do [ -n "$f" ] && failed+=("$f"); done < <(deploy_batch "${retry[@]}")
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "== All $total functions deployed."
else
  echo "== Still failing: ${failed[*]}"
  echo "   Rerun later with: bash scripts/deploy-functions.sh ${failed[*]}"
  exit 1
fi
