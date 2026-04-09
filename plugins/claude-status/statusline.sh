#!/usr/bin/env bash
# Claude Code statusline — Nerd Font icons, progress bars, latency indicator

source "$(dirname "$0")/latency-common.sh"

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
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

make_bar() {
  local pct=$1
  local filled=$(( pct * 10 / 100 ))
  local empty=$(( 10 - filled ))
  local bar="" i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
  printf "%s" "$bar"
}

ctx_segment=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar=$(make_bar "$used_int")
  ctx_segment=" |  [${bar}] ${used_int}%"
fi

rate_segment=""
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  bar=$(make_bar "$five_int")
  rate_segment=" |  [${bar}] ${five_int}%"
fi

latency_segment=""
if claude_latency_read; then
  case "$CLAUDE_LATENCY_LEVEL" in
    normal)      _lcolor="\033[0;32m" ;;   # green
    warn)        _lcolor="\033[0;33m" ;;   # yellow
    peak)        _lcolor="\033[0;31m" ;;   # red
    unavailable) _lcolor="\033[0;90m" ;;   # grey
    *)           _lcolor="\033[0m"    ;;
  esac
  if [ -n "$CLAUDE_LATENCY_MS" ] && [ "$CLAUDE_LATENCY_MS" != "null" ]; then
    latency_segment=" | ${_lcolor}${CLAUDE_LATENCY_ICON} ${CLAUDE_LATENCY_MS}ms\033[0m"
  else
    latency_segment=" | ${_lcolor}${CLAUDE_LATENCY_ICON}\033[0m"
  fi
fi

printf "\033[1;36m%s@%s\033[0m" "$user" "$host"
printf " \033[0;33m %s\033[0m" "$short_cwd"

if [ -n "$git_branch" ]; then
  printf " \033[0;32m %s\033[0m" "$git_branch"
fi

if [ -n "$model" ]; then
  printf " \033[2m %s\033[0m" "$model"
fi

printf "%s%s%b\n" "$ctx_segment" "$rate_segment" "$latency_segment"
