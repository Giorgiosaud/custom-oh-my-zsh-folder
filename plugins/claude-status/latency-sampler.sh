#!/usr/bin/env bash
# Measures TCP latency to api.anthropic.com:443, appends to rolling log, writes level cache.

LOG="$HOME/.claude/latency_log.json"
CACHE="$HOME/.claude/latency_cache.json"
HOST="api.anthropic.com"
PORT=443
TIMEOUT=10

mkdir -p "$HOME/.claude"

# --- Measure TCP latency via nc ---
ms="unavailable"
start=$(python3 -c "import time; print(int(time.time()*1000))")
if nc -z -w "$TIMEOUT" "$HOST" "$PORT" 2>/dev/null; then
  end=$(python3 -c "import time; print(int(time.time()*1000))")
  ms=$(( end - start ))
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
cutoff=$(( now - 7 * 86400 ))

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

if len(samples) >= 3:
    baseline = statistics.median(samples)
    ratio = $ms / baseline
    if ratio < 1.4:
        level = "normal"
    elif ratio < 2.0:
        level = "warn"
    else:
        level = "peak"
    result = {"ms": $ms, "baseline": round(baseline), "ratio": round(ratio, 2), "level": level}
else:
    result = {"ms": $ms, "baseline": None, "ratio": None, "level": "normal"}

with open("$CACHE", "w") as f:
    json.dump(result, f)
PYEOF
