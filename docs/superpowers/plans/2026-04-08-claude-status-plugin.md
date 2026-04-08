# claude-status Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a self-installing zsh plugin that consolidates the Claude Code statusline and a background API latency sampler with a 4-level peak-time indicator.

**Architecture:** A single oh-my-zsh custom plugin containing the statusline script, latency sampler, and launchd plist. On shell load the plugin auto-installs the launchd job and syncs the statusline script. The sampler writes JSON cache files read by the statusline at render time.

**Tech Stack:** bash/zsh, launchd (macOS), `/dev/tcp` for TCP latency, jq for JSON, Nerd Font glyphs (MesloLGS NF)

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `plugins/claude-status/claude-status.plugin.zsh` | Create | Plugin entry point — syncs statusline, installs launchd |
| `plugins/claude-status/statusline.sh` | Create (move from `~/.claude/`) | Statusline renderer — reads harness JSON, outputs formatted line |
| `plugins/claude-status/latency-sampler.sh` | Create | TCP ping, log append, cache write |
| `plugins/claude-status/com.claude.latency.plist` | Create | launchd plist template with `__SAMPLER_PATH__` placeholder |

**Runtime files (written at runtime, not tracked):**
- `~/.claude/statusline-command.sh` — synced copy of `statusline.sh`
- `~/.claude/latency_log.json` — rolling 7-day history
- `~/.claude/latency_cache.json` — latest level + ms
- `~/Library/LaunchAgents/com.claude.latency.plist` — rendered plist
- `~/.claude/latency-sampler.log` — sampler stdout/stderr

---

### Task 1: Create plugin directory and plist template

**Files:**
- Create: `plugins/claude-status/com.claude.latency.plist`

- [ ] **Step 1: Create plugin directory**

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins/claude-status
```

- [ ] **Step 2: Write the launchd plist template**

Create `plugins/claude-status/com.claude.latency.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.latency</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>__SAMPLER_PATH__</string>
    </array>
    <key>StartInterval</key>
    <integer>900</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>__HOME__/.claude/latency-sampler.log</string>
    <key>StandardErrorPath</key>
    <string>__HOME__/.claude/latency-sampler.log</string>
</dict>
</plist>
```

- [ ] **Step 3: Commit**

```bash
git add plugins/claude-status/com.claude.latency.plist
git commit -m "feat(claude-status): add launchd plist template"
```

---

### Task 2: Write the latency sampler script

**Files:**
- Create: `plugins/claude-status/latency-sampler.sh`

- [ ] **Step 1: Write the sampler script**

Create `plugins/claude-status/latency-sampler.sh`:

```bash
#!/usr/bin/env bash
# Measures TCP latency to api.anthropic.com:443, appends to log, writes cache.

set -euo pipefail

LOG="$HOME/.claude/latency_log.json"
CACHE="$HOME/.claude/latency_cache.json"
HOST="api.anthropic.com"
PORT=443
TIMEOUT=10  # seconds

mkdir -p "$HOME/.claude"

# --- Measure TCP latency ---
measure_ms() {
  local start end
  start=$(python3 -c "import time; print(int(time.time()*1000))")
  if ! (echo >/dev/tcp/"$HOST"/"$PORT") 2>/dev/null & then
    wait $! 2>/dev/null || true
  fi
  # Use nc as primary method (more reliable than /dev/tcp in bash)
  if nc -z -w "$TIMEOUT" "$HOST" "$PORT" 2>/dev/null; then
    end=$(python3 -c "import time; print(int(time.time()*1000))")
    echo $(( end - start ))
  else
    echo "unavailable"
  fi
}

ms=$(measure_ms)

# --- Handle unavailable ---
if [ "$ms" = "unavailable" ]; then
  echo "{\"ms\": null, \"baseline\": null, \"ratio\": null, \"level\": \"unavailable\"}" > "$CACHE"
  exit 0
fi

# --- Append to log ---
now=$(date +%s)
hour=$(date +%H | sed 's/^0//')
weekday=$(date +%u)  # 1=Mon ... 7=Sun

# Initialize log if missing
[ -f "$LOG" ] || echo "[]" > "$LOG"

# Append entry and prune entries older than 7 days
cutoff=$(( now - 7 * 86400 ))
python3 - <<PYEOF
import json, sys

log_path = "$LOG"
with open(log_path) as f:
    log = json.load(f)

# Append new entry
log.append({"ts": $now, "ms": $ms, "hour": $hour, "weekday": $weekday})

# Prune old entries
log = [e for e in log if e["ts"] >= $cutoff]

with open(log_path, "w") as f:
    json.dump(log, f)
PYEOF

# --- Compute baseline (same weekday, hour ± 1, last 7 days, excluding current entry) ---
baseline=$(python3 - <<PYEOF
import json, statistics

with open("$LOG") as f:
    log = json.load(f)

current_ts = $now
hour = $hour
weekday = $weekday

samples = [
    e["ms"] for e in log
    if e["weekday"] == weekday
    and abs(e["hour"] - hour) <= 1
    and e["ts"] != current_ts
    and e["ms"] is not None
]

if len(samples) >= 3:
    print(statistics.median(samples))
else:
    print("none")
PYEOF
)

# --- Determine level and write cache ---
if [ "$baseline" = "none" ]; then
  # Not enough history — show ms only, no level
  echo "{\"ms\": $ms, \"baseline\": null, \"ratio\": null, \"level\": \"normal\"}" > "$CACHE"
else
  python3 - <<PYEOF
import json

ms = $ms
baseline = float("$baseline")
ratio = ms / baseline if baseline > 0 else 0

if ratio < 1.4:
    level = "normal"
elif ratio < 2.0:
    level = "warn"
else:
    level = "peak"

with open("$CACHE", "w") as f:
    json.dump({"ms": ms, "baseline": round(baseline), "ratio": round(ratio, 2), "level": level}, f)
PYEOF
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x plugins/claude-status/latency-sampler.sh
```

- [ ] **Step 3: Smoke test the sampler manually**

```bash
bash ~/.oh-my-zsh/custom/plugins/claude-status/latency-sampler.sh
cat ~/.claude/latency_cache.json
```

Expected output (values will vary):
```json
{"ms": 145, "baseline": null, "ratio": null, "level": "normal"}
```

The first run always shows `"baseline": null` since there's no history yet.

- [ ] **Step 4: Commit**

```bash
git add plugins/claude-status/latency-sampler.sh
git commit -m "feat(claude-status): add latency sampler script"
```

---

### Task 3: Write the statusline script with latency indicator

**Files:**
- Create: `plugins/claude-status/statusline.sh`

This replaces the current `~/.claude/statusline-command.sh`. The plugin entry point will sync it there.

- [ ] **Step 1: Write statusline.sh using Python to embed Nerd Font bytes correctly**

Run this to create the file with correct Unicode bytes:

```bash
python3 << 'PYEOF'
script = '''\
#!/usr/bin/env bash
# Claude Code statusline — Nerd Font icons, progress bars, latency indicator

CACHE="$HOME/.claude/latency_cache.json"

input=$(cat)

cwd=$(echo "$input"    | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"  | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

user=$(whoami)
host=$(hostname -s)

home="$HOME"
short_cwd="${cwd/#$home/~}"

git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \\
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

make_bar() {
  local pct=$1
  local filled=$(( pct * 10 / 100 ))
  local empty=$(( 10 - filled ))
  local bar="" i
  for (( i=0; i<filled; i++ )); do bar="${bar}\u2588"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}\u2591"; done
  printf "%s" "$bar"
}

ctx_segment=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar=$(make_bar "$used_int")
  ctx_segment=" | \uf080 [${bar}] ${used_int}%"
fi

rate_segment=""
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  bar=$(make_bar "$five_int")
  rate_segment=" | \uf017 [${bar}] ${five_int}%"
fi

latency_segment=""
if [ -f "$CACHE" ]; then
  level=$(jq -r '.level // "normal"' "$CACHE" 2>/dev/null)
  ms=$(jq -r '.ms // ""' "$CACHE" 2>/dev/null)
  case "$level" in
    normal)      icon="\uf0e7" ;;
    warn)        icon="\uf071" ;;
    peak)        icon="\uf21e" ;;
    unavailable) icon="\ufba4" ;;
    *)           icon="\uf0e7" ;;
  esac
  if [ -n "$ms" ] && [ "$ms" != "null" ]; then
    latency_segment=" | ${icon} ${ms}ms"
  else
    latency_segment=" | ${icon}"
  fi
fi

printf "\\033[1;36m%s@%s\\033[0m" "$user" "$host"
printf " \\033[0;33m\uf07b %s\\033[0m" "$short_cwd"

if [ -n "$git_branch" ]; then
  printf " \\033[0;32m\ue0a0 %s\\033[0m" "$git_branch"
fi

if [ -n "$model" ]; then
  printf " \\033[2m\uf544 %s\\033[0m" "$model"
fi

printf "%s%s%s\\n" "$ctx_segment" "$rate_segment" "$latency_segment"
'''

with open('/Users/bepartnerlabs/.oh-my-zsh/custom/plugins/claude-status/statusline.sh', 'w', encoding='utf-8') as f:
    f.write(script)
print("Written.")
PYEOF
```

- [ ] **Step 2: Make executable**

```bash
chmod +x plugins/claude-status/statusline.sh
```

- [ ] **Step 3: Smoke test — normal level**

First ensure cache exists with a known state:
```bash
echo '{"ms": 142, "baseline": 130, "ratio": 1.09, "level": "normal"}' > ~/.claude/latency_cache.json
```

Then test:
```bash
echo '{"workspace":{"current_dir":"/Users/bepartnerlabs/projects/test"},"model":{"display_name":"Claude Sonnet 4.6"},"context_window":{"used_percentage":35},"rate_limits":{"five_hour":{"used_percentage":10}}}' \
  | bash ~/.oh-my-zsh/custom/plugins/claude-status/statusline.sh
```

Expected: line ending with `|  142ms` (bolt icon)

- [ ] **Step 4: Smoke test — warn level**

```bash
echo '{"ms": 210, "baseline": 130, "ratio": 1.61, "level": "warn"}' > ~/.claude/latency_cache.json
echo '{"workspace":{"current_dir":"/Users/bepartnerlabs"},"model":{"display_name":"Claude Sonnet 4.6"},"context_window":{"used_percentage":50},"rate_limits":{"five_hour":{"used_percentage":20}}}' \
  | bash ~/.oh-my-zsh/custom/plugins/claude-status/statusline.sh
```

Expected: line ending with `|  210ms` (exclamation-triangle icon)

- [ ] **Step 5: Smoke test — unavailable level**

```bash
echo '{"ms": null, "baseline": null, "ratio": null, "level": "unavailable"}' > ~/.claude/latency_cache.json
echo '{"workspace":{"current_dir":"/Users/bepartnerlabs"},"model":{"display_name":"Claude Sonnet 4.6"},"context_window":{"used_percentage":50},"rate_limits":{"five_hour":{"used_percentage":20}}}' \
  | bash ~/.oh-my-zsh/custom/plugins/claude-status/statusline.sh
```

Expected: line ending with `| ` (shield-alert icon, no ms)

- [ ] **Step 6: Commit**

```bash
git add plugins/claude-status/statusline.sh
git commit -m "feat(claude-status): add statusline script with latency indicator"
```

---

### Task 4: Write the plugin entry point

**Files:**
- Create: `plugins/claude-status/claude-status.plugin.zsh`

- [ ] **Step 1: Write the plugin entry point**

Create `plugins/claude-status/claude-status.plugin.zsh`:

```zsh
# claude-status plugin
# Syncs the statusline script and auto-installs the launchd latency sampler.

_claude_status_dir="${0:A:h}"
_claude_plist_label="com.claude.latency"
_claude_plist_dest="$HOME/Library/LaunchAgents/com.claude.latency.plist"
_claude_plist_src="$_claude_status_dir/com.claude.latency.plist"
_claude_sampler="$_claude_status_dir/latency-sampler.sh"
_claude_statusline_dest="$HOME/.claude/statusline-command.sh"

# 1. Ensure ~/.claude exists
mkdir -p "$HOME/.claude"

# 2. Sync statusline script
cp "$_claude_status_dir/statusline.sh" "$_claude_statusline_dest"
chmod +x "$_claude_statusline_dest"

# 3. Render and install launchd plist (idempotent)
_claude_install_launchd() {
  # Render plist with real paths
  sed \
    -e "s|__SAMPLER_PATH__|$_claude_sampler|g" \
    -e "s|__HOME__|$HOME|g" \
    "$_claude_plist_src" > "$_claude_plist_dest"

  # Load if not already loaded
  if ! launchctl list "$_claude_plist_label" &>/dev/null; then
    launchctl bootstrap "gui/$(id -u)" "$_claude_plist_dest" 2>/dev/null \
      || launchctl load "$_claude_plist_dest" 2>/dev/null \
      || true
  fi
}

_claude_install_launchd

unset _claude_status_dir _claude_plist_label _claude_plist_dest \
      _claude_plist_src _claude_sampler _claude_statusline_dest
```

- [ ] **Step 2: Commit**

```bash
git add plugins/claude-status/claude-status.plugin.zsh
git commit -m "feat(claude-status): add plugin entry point with auto launchd install"
```

---

### Task 5: Register the plugin and remove old statusline

**Files:**
- Modify: `~/.zshrc` — add `claude-status` to plugins array
- Delete: `~/.claude/statusline-command.sh` — now managed by plugin

- [ ] **Step 1: Add plugin to .zshrc**

Open `~/.zshrc` and find the `plugins=(...)` line. Add `claude-status`:

```zsh
plugins=(
  ...existing plugins...
  claude-status
)
```

- [ ] **Step 2: Remove old standalone statusline (plugin will sync it)**

```bash
rm -f ~/.claude/statusline-command.sh
```

- [ ] **Step 3: Reload shell to test**

```bash
exec zsh
```

Expected: shell loads without errors. Check that the synced file exists:

```bash
ls -la ~/.claude/statusline-command.sh
launchctl list com.claude.latency
```

Expected:
- `statusline-command.sh` exists and is executable
- `launchctl list` shows the job (non-empty output, exit 0)

- [ ] **Step 4: Verify sampler ran**

Wait ~5 seconds (RunAtLoad fires on first load), then:

```bash
cat ~/.claude/latency_cache.json
```

Expected: valid JSON with `ms`, `level` fields.

- [ ] **Step 5: Verify statusline renders with latency**

```bash
echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Claude Sonnet 4.6"},"context_window":{"used_percentage":20},"rate_limits":{"five_hour":{"used_percentage":5}}}' \
  | bash ~/.claude/statusline-command.sh
```

Expected: output includes a latency icon and ms value at the end.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(claude-status): register plugin, remove standalone statusline"
```

---

### Task 6: Verify Claude Code statusline end-to-end

- [ ] **Step 1: Open Claude Code and confirm statusline renders**

Open Claude Code CLI. The status bar should show the full line including the latency segment. Confirm all icons render (MesloLGS NF required).

- [ ] **Step 2: Simulate peak latency to verify icon switching**

```bash
echo '{"ms": 450, "baseline": 130, "ratio": 3.46, "level": "peak"}' > ~/.claude/latency_cache.json
```

Trigger a statusline refresh (send any message in Claude Code). The latency segment should show the heartbeat icon (`U+F21E`).

- [ ] **Step 3: Restore real cache**

```bash
bash ~/.oh-my-zsh/custom/plugins/claude-status/latency-sampler.sh
cat ~/.claude/latency_cache.json
```

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat(claude-status): complete plugin with latency peak indicator"
```
