# claude-status

An oh-my-zsh plugin that shows Claude API latency in your terminal prompt and Claude Code statusline.

## What It Does

- **Powerlevel10k segment** — auto-registered on the right prompt, no manual config needed
- **Claude Code statusline** — register with a single command
- **Background sampler** — macOS launchd job pings `api.anthropic.com:443` every 60s, no tokens consumed

### Latency levels

| Icon | Color | Condition |
|------|-------|-----------|
| bolt | Green | Normal — within 1 stdev of baseline |
| warning | Yellow | Elevated — 1–2 stdev above baseline |
| heartbeat | Red | Peak — > 2 stdev above baseline |
| shield | Grey | Unavailable — TCP timeout |

The baseline is the median of samples taken at the same hour (+/-1) and weekday over the last 30 days. Requires 30+ samples before statistical thresholds activate.

---

## Installation

### 1. Enable the plugin

In `~/.zshrc` (inside your `plugins=(...)` list):

```zsh
plugins=(
  ...
  claude-status
)
```

### 2. Reload

```zsh
exec zsh
```

That's it. The plugin will:
- Auto-register the `claude_latency` p10k segment on the right prompt
- Install the launchd job (`com.giorgiosaud.claude.latency`) to sample every 60 seconds

### 3. Register Claude Code statusline (optional, one-time)

```zsh
claude-status-register
```

This writes the statusline config to `~/.claude/settings.json`. Restart Claude Code to apply.

---

## Dependencies

All standard on macOS:

| Tool | Purpose |
|------|---------|
| `nc` | TCP latency measurement |
| `python3` | Log management and baseline calculation |
| `jq` | JSON parsing in statusline and segment |
| MesloLGS NF | Nerd Font required to render icons |

Install jq if missing: `brew install jq`

---

## File Layout

All scripts live in the plugin directory — nothing is copied outside.

| Plugin file | Purpose |
|-------------|---------|
| `claude-status.plugin.zsh` | Plugin init, p10k segment, auto-register |
| `latency-common.sh` | Shared cache reader (sourced by statusline + segment) |
| `latency-sampler.sh` | TCP ping + baseline calculation (run by launchd) |
| `statusline.sh` | Claude Code statusline renderer |
| `com.giorgiosaud.claude.latency.plist` | launchd job template |

### Runtime files (created automatically)

| File | Description |
|------|-------------|
| `~/.claude/latency_log.json` | Rolling 30-day sample history |
| `~/.claude/latency_cache.json` | Latest result read by prompt and statusline |
| `~/.claude/latency-sampler.log` | Sampler stdout/stderr |
| `~/Library/LaunchAgents/com.giorgiosaud.claude.latency.plist` | Rendered launchd plist |

---

## Troubleshooting

**Segment not showing:**
- Run `p10k reload` — the auto-register runs on first `precmd` after p10k loads
- Verify: `print -l $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` should include `claude_latency`

**Icons not rendering:**
- Confirm your terminal font is MesloLGS NF (or another Nerd Font)

**Cache not updating:**
- Check `launchctl list com.giorgiosaud.claude.latency` — if missing, run `exec zsh` to reinstall
- Check `~/.claude/latency-sampler.log` for errors
