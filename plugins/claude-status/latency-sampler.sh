#!/usr/bin/env bash
# Measures HTTP latency to api.anthropic.com, appends to rolling log, writes level cache.
# Uses an unauthenticated POST (gets 401) to measure full HTTP stack — no API key or tokens needed.

LOG="$HOME/.claude/latency_log.json"
CACHE="$HOME/.claude/latency_cache.json"
TIMEOUT=10

mkdir -p "$HOME/.claude"

# --- Keep the sampler's own log small (launchd appends stdout/stderr to it) ---
SAMPLER_LOG="$HOME/.claude/latency-sampler.log"
SAMPLER_LOG_MAX_BYTES=262144   # 256 KB; past that, keep the last 200 lines
if [ -f "$SAMPLER_LOG" ] && [ "$(stat -f %z "$SAMPLER_LOG")" -gt "$SAMPLER_LOG_MAX_BYTES" ]; then
  tail -n 200 "$SAMPLER_LOG" > "$SAMPLER_LOG.tmp" && mv "$SAMPLER_LOG.tmp" "$SAMPLER_LOG"
fi

# --- Count consecutive failed runs (latency-common.sh shows an error past a
# threshold); a successful run, including "API unreachable", resets it ---
FAILURES="$HOME/.claude/latency_failures"
trap 'rc=$?
if [ "$rc" -eq 0 ]; then
  echo 0 > "$FAILURES"
else
  echo $(( $(cat "$FAILURES" 2>/dev/null || echo 0) + 1 )) > "$FAILURES"
fi' EXIT

# --- Measure HTTP latency via curl (401 response, no tokens consumed) ---
ms="unavailable"
curl_time=$(curl -s -o /dev/null -w "%{time_total}" \
  --max-time "$TIMEOUT" \
  -X POST \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
  "https://api.anthropic.com/v1/messages" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$curl_time" ]; then
  ms=$(python3 -c "print(int(float('$curl_time') * 1000))")
fi

# --- Handle unavailable ---
if [ "$ms" = "unavailable" ]; then
  echo '{"ms": null, "baseline": null, "ratio": null, "level": "unavailable"}' > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
  exit 0
fi

# --- Append to log and prune entries older than 7 days ---
# -s, not -f: an empty file (e.g. truncated by an interrupted write) also starts over.
[ -s "$LOG" ] || echo "[]" > "$LOG"

now=$(date +%s)
hour=$(date +%-H)
weekday=$(date +%u)
cutoff=$(( now - 30 * 86400 ))

python3 - <<PYEOF
import json, os, statistics

# Writes go to a temp file and are renamed over the target, so a run cut
# short never leaves a truncated file behind.
def write_json(path, data):
    with open(path + ".tmp", "w") as f:
        json.dump(data, f)
    os.replace(path + ".tmp", path)

try:
    with open("$LOG") as f:
        log = json.load(f)
except (OSError, ValueError):
    log = []  # corrupt log: start over instead of failing every run

log.append({"ts": $now, "ms": $ms, "hour": $hour, "weekday": $weekday})
log = [e for e in log if e["ts"] >= $cutoff]

write_json("$LOG", log)

# Compute baseline: same weekday, hour ±1, excluding current entry
samples = [
    e["ms"] for e in log
    if e["weekday"] == $weekday
    and abs(e["hour"] - $hour) <= 1
    and e["ts"] != $now
    and e["ms"] is not None
]

if len(samples) >= 30:
    baseline = statistics.median(samples)
    stdev = statistics.stdev(samples)
    warn_threshold = baseline + stdev       # ~84th percentile
    peak_threshold = baseline + 2 * stdev   # ~97.5th percentile
    if $ms > peak_threshold:
        level = "peak"
    elif $ms > warn_threshold:
        level = "warn"
    else:
        level = "normal"
    result = {
        "ms": $ms,
        "baseline": round(baseline),
        "stdev": round(stdev),
        "warn_threshold": round(warn_threshold),
        "peak_threshold": round(peak_threshold),
        "level": level,
        "samples": len(samples),
    }
else:
    result = {"ms": $ms, "baseline": None, "stdev": None, "level": "normal", "samples": len(samples)}

write_json("$CACHE", result)
PYEOF
