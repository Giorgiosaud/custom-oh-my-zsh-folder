#!/usr/bin/env bash
# Shared latency cache reader — sourced by statusline.sh and the p10k segment.
# Sets: CLAUDE_LATENCY_LEVEL, CLAUDE_LATENCY_MS, CLAUDE_LATENCY_ICON

CLAUDE_LATENCY_CACHE="$HOME/.claude/latency_cache.json"

claude_latency_read() {
  CLAUDE_LATENCY_LEVEL=""
  CLAUDE_LATENCY_MS=""
  CLAUDE_LATENCY_ICON=""

  [[ -f "$CLAUDE_LATENCY_CACHE" ]] || return 1

  CLAUDE_LATENCY_LEVEL=$(jq -r '.level // "normal"' "$CLAUDE_LATENCY_CACHE" 2>/dev/null) || return 1
  CLAUDE_LATENCY_MS=$(jq -r '.ms // ""' "$CLAUDE_LATENCY_CACHE" 2>/dev/null)

  case "$CLAUDE_LATENCY_LEVEL" in
    normal)      CLAUDE_LATENCY_ICON=$(printf '\xef\x83\xa7') ;;   # U+F0E7 bolt
    warn)        CLAUDE_LATENCY_ICON=$(printf '\xef\x81\xb1') ;;   # U+F071 warning
    peak)        CLAUDE_LATENCY_ICON=$(printf '\xef\x88\x9e') ;;   # U+F21E heartbeat
    unavailable) CLAUDE_LATENCY_ICON=$(printf '\xef\xae\xa4') ;;   # U+FBA4 shield
    *)           return 1 ;;
  esac
}
