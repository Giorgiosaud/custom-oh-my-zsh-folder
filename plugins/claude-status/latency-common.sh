#!/usr/bin/env bash
# Shared latency cache reader — sourced by statusline.sh and the p10k segment.
# Sets: CLAUDE_LATENCY_LEVEL, CLAUDE_LATENCY_MS, CLAUDE_LATENCY_ICON
# Level "error": the sampler failed CLAUDE_LATENCY_MAX_FAILURES runs in a row,
# or stopped updating the cache: check ~/.claude/latency-sampler.log.

CLAUDE_LATENCY_CACHE="$HOME/.claude/latency_cache.json"
# Older than this (seconds) the cache is stale (sampler stopped or failing):
# show nothing rather than an old reading.
CLAUDE_LATENCY_MAX_AGE="${CLAUDE_LATENCY_MAX_AGE:-300}"
CLAUDE_LATENCY_FAILURES="$HOME/.claude/latency_failures"
CLAUDE_LATENCY_MAX_FAILURES="${CLAUDE_LATENCY_MAX_FAILURES:-5}"

claude_latency_read() {
  CLAUDE_LATENCY_LEVEL=""
  CLAUDE_LATENCY_MS=""
  CLAUDE_LATENCY_ICON=""

  [[ -f "$CLAUDE_LATENCY_CACHE" ]] || return 1

  local mtime failures
  failures=$(cat "$CLAUDE_LATENCY_FAILURES" 2>/dev/null)
  mtime=$(stat -f %m "$CLAUDE_LATENCY_CACHE" 2>/dev/null) || mtime=0
  if (( ${failures:-0} >= CLAUDE_LATENCY_MAX_FAILURES )) \
     || (( $(date +%s) - mtime > CLAUDE_LATENCY_MAX_AGE )); then
    CLAUDE_LATENCY_LEVEL="error"
    CLAUDE_LATENCY_ICON=$(printf '\xef\x81\xaa')   # U+F06A exclamation-circle
    return 0
  fi

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
