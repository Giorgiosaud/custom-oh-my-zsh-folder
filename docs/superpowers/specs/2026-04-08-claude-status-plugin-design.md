# claude-status Plugin Design

**Date:** 2026-04-08  
**Status:** Approved

## Overview

A zsh plugin that consolidates the Claude Code statusline and a background API latency sampler into a single self-installing package. The plugin auto-installs a launchd job on shell load and exposes a latency-based peak-time indicator in the Claude Code statusline.

## Plugin Structure

```
~/.oh-my-zsh/custom/plugins/claude-status/
├── claude-status.plugin.zsh     # entry point — auto-installs launchd, syncs statusline
├── statusline.sh                # statusline script (replaces ~/.claude/statusline-command.sh)
├── latency-sampler.sh           # ping script executed by launchd every 15min
└── com.claude.latency.plist     # launchd plist template
```

### Runtime data (written by sampler)

```
~/.claude/latency_log.json       # rolling 7-day history: [{ts, ms, hour, weekday}]
~/.claude/latency_cache.json     # latest result: {ms, baseline, ratio, level}
```

## Components

### claude-status.plugin.zsh

Runs on every shell load. Responsibilities:

1. Copies `statusline.sh` → `~/.claude/statusline-command.sh` (settings.json path stays stable)
2. Renders `com.claude.latency.plist` → `~/Library/LaunchAgents/com.claude.latency.plist` with resolved absolute paths
3. Loads the launchd job with `launchctl bootstrap` if not already loaded — silent, no user prompt
4. Skips steps 2-3 if plist is already loaded and up to date (idempotent)

### latency-sampler.sh

Executed by launchd every 15 minutes. Responsibilities:

1. TCP-connects to `api.anthropic.com:443` using `/dev/tcp` or `nc`, measures milliseconds to handshake
2. On timeout/failure: writes `level: unavailable` to cache, exits
3. Appends `{ts, ms, hour, weekday}` entry to `latency_log.json`
4. Prunes entries older than 7 days
5. Computes baseline = median of entries matching `hour ± 1` and same `weekday` (min 3 samples required; skips baseline if insufficient data)
6. Computes `ratio = current_ms / baseline`
7. Writes `latency_cache.json`: `{ms, baseline, ratio, level}`

### statusline.sh

Reads JSON from stdin (Claude Code harness), outputs a formatted status line. Segments:

| Segment | Icon | Color |
|---------|------|-------|
| user@host | — | bold cyan |
| directory | `U+F07B` | yellow |
| git branch | `U+E0A0` | green |
| model | `U+F544` | dim |
| context bar | `U+F080` | — |
| rate limit bar | `U+F017` | — |
| latency indicator | level-dependent | — |

Progress bars use `█` (filled) / `░` (empty) across 10 cells.

### Latency indicator levels

| Level | Icon | Codepoint | Condition |
|-------|------|-----------|-----------|
| normal | bolt | U+F0E7 | ratio < 1.4 |
| warn | exclamation-triangle | U+F071 | 1.4 ≤ ratio < 2.0 |
| peak | heartbeat | U+F21E | ratio ≥ 2.0 |
| unavailable | shield-alert | U+FBA4 | TCP failure / timeout |

The latency segment only appears once `latency_cache.json` exists (first sample after install). When fewer than 3 historical samples exist for the current time window, only the raw `ms` is shown without a level icon.

### com.claude.latency.plist

Standard launchd plist:
- `StartInterval`: 900 (15 minutes)
- `RunAtLoad`: true (runs once immediately on load)
- `StandardOutPath` / `StandardErrorPath`: `~/.claude/latency-sampler.log`

## Data Format

### latency_log.json
```json
[
  {"ts": 1712345678, "ms": 142, "hour": 14, "weekday": 2},
  ...
]
```

### latency_cache.json
```json
{"ms": 198, "baseline": 145, "ratio": 1.37, "level": "normal"}
```

## Font Requirements

Requires MesloLGS NF (or any Nerd Font). All icon codepoints are in the Font Awesome v4 / Powerline range supported by MesloLGS NF.

## Migration

The existing `~/.claude/statusline-command.sh` and `~/.claude/settings.json` are unchanged in path — the plugin writes to the same path, so no changes to Claude Code settings are needed.
