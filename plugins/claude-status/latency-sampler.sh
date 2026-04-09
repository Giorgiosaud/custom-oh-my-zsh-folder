#!/usr/bin/env bash
# Measures HTTP latency to api.anthropic.com, appends to rolling log, writes level cache.
# Uses an unauthenticated POST (gets 401) to measure full HTTP stack — no API key or tokens needed.

LOG="$HOME/.claude/latency_log.json"
CACHE="$HOME/.claude/latency_cache.json"
TIMEOUT=10

mkdir -p "$HOME/.claude"

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
  echo '{"ms": null, "baseline": null, "ratio": null, "level": "unavailable"}' > "$CACHE"
  exit 0
fi

# --- Append to log and prune entries older than 7 days ---
[ -f "$LOG" ] || echo "[]" > "$LOG"

now=$(date +%s)
hour=$(date +%-H)
weekday=$(date +%u)
cutoff=$(( now - 30 * 86400 ))

python3 - <<PYEOF
import json, statistics

with open("$LOG") as f:
    log = json.load(f)

log.append({"ts": $now, "ms": $ms, "hour": $hour, "weekday": $weekday})
log = [e for e in log if e["ts"] >= $cutoff]

with open("$LOG", "w") as f:
    json.dump(log, f)

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

with open("$CACHE", "w") as f:
    json.dump(result, f)
PYEOF
