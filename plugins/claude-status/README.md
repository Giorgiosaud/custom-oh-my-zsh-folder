# claude-status

An oh-my-zsh plugin that shows Claude API load in your terminal prompt and Claude Code statusline.

## What It Does

- **Powerlevel10k segment** — shows a Nerd Font icon + latency (ms) on the right prompt
- **Claude Code statusline** — adds the same indicator to the Claude Code status bar
- **Background sampler** — launchd job pings `api.anthropic.com:443` every 15 min, no tokens consumed

### Latency levels

| Icon | Color | Condition |
|------|-------|-----------|
|  (bolt) | Green | Normal — < 1.4× baseline |
|  (warning) | Yellow | Elevated — 1.4× – 2× baseline |
|  (heartbeat) | Red | Peak — > 2× baseline |
|  (shield) | Grey | Unavailable — TCP timeout |

The baseline is the median of samples taken at the same hour (±1) and weekday over the last 7 days. Until 3 samples exist for the current time window, only the raw ms is shown.

---

## Installation

### 1. Pull the repo

```zsh
cd ~/.oh-my-zsh/custom
git pull
```

### 2. Add the plugin to your zshrc

In `~/.oh-my-zsh/custom/zshrc` (or wherever your `plugins=(...)` list lives):

```zsh
plugins=(
  ...
  claude-status
)
```

### 3. Add the Powerlevel10k segment (manual — `~/.p10k.zsh` is not in this repo)

Open `~/.p10k.zsh` and find `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`. Add `claude_latency` at the end:

```zsh
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  # ... existing segments ...
  claude_latency
)
```

### 4. Reload

Open a new iTerm tab (or run `exec zsh`). The plugin will:
- Sync the Claude Code statusline script to `~/.claude/statusline-command.sh`
- Install and start the launchd job `com.claude.latency` automatically
- Begin sampling after ~15 seconds (RunAtLoad)

Run `p10k reload` if the segment doesn't appear immediately.

---

## Dependencies

All are standard on macOS:

| Tool | Purpose |
|------|---------|
| `nc` | TCP latency measurement |
| `python3` | Log management and baseline calculation |
| `jq` | JSON parsing in statusline and segment |
| MesloLGS NF | Nerd Font required to render icons |

Install jq if missing: `brew install jq`

---

## Runtime Files

| File | Description |
|------|-------------|
| `~/.claude/statusline-command.sh` | Synced on every shell load |
| `~/.claude/latency_log.json` | Rolling 7-day history (max ~35KB) |
| `~/.claude/latency_cache.json` | Latest result read by prompt and statusline |
| `~/.claude/latency-sampler.log` | Sampler stdout/stderr |
| `~/Library/LaunchAgents/com.claude.latency.plist` | Rendered launchd plist |

---

## Troubleshooting

**Segment not showing after pull on a new Mac:**
- Check `~/.p10k.zsh` has `claude_latency` in `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`
- Run `p10k reload`

**Icons not rendering:**
- Confirm your terminal font is MesloLGS NF (or another Nerd Font)

**Cache not updating:**
- Check `launchctl list com.claude.latency` — if missing, run `exec zsh` to reinstall
- Check `~/.claude/latency-sampler.log` for errors
