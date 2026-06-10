#!/usr/bin/env bash
# Claude Code statusline — single-line compact layout

source "$(dirname "$0")/latency-common.sh"

input=$(cat)

cwd=$(echo "$input"         | jq -r '.workspace.current_dir // .cwd // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
model=$(echo "$input"       | jq -r '.model.display_name // ""')
pr_number=$(echo "$input"   | jq -r '.pr.number // empty')
pr_state=$(echo "$input"    | jq -r '.pr.review_state // empty')
used_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Path: last component only
short_cwd=$(basename "$cwd")
[ -z "$short_cwd" ] && short_cwd="/"

# Model: last segment only (e.g. "claude-sonnet-4-6" → "sonnet-4-6")
model=$(echo "$model" | sed 's/^claude-//')

git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# ── ANSI helpers ─────────────────────────────────────────────────────────────
fg()  { printf "\033[38;5;%sm" "$1"; }
bg()  { printf "\033[48;5;%sm" "$1"; }
dim() { printf "\033[2m"; }
rst() { printf "\033[0m"; }

# Separators — ASCII only (powerline glyphs cause iTerm2 width miscalculation)
SEP_FULL="|"
SEP_THIN=":"

# Palette
C_PATH_BG=238   # dark grey
C_PATH_FG=252   # light grey
C_GIT_BG=22     # dark green
C_GIT_FG=157    # bright mint
C_MDL_BG=235    # near-black
C_MDL_FG=244    # medium grey
C_INFO_FG=245   # muted grey

# Usage color: green -> yellow -> orange -> red
usage_color() {
  local pct=$1
  if   [ "$pct" -lt 50 ]; then printf "82"
  elif [ "$pct" -lt 75 ]; then printf "226"
  elif [ "$pct" -lt 90 ]; then printf "208"
  else                          printf "196"
  fi
}

inline_sep() {
  printf "%b %s %b" "$(fg 239)" "$SEP_THIN" "$(fg $C_INFO_FG)"
}

# ── SEGMENTS (flat, ASCII separators — safe for iTerm2) ──────────────────────
printf "%b %s " "$(fg $C_PATH_FG)" "$short_cwd"

if [ -n "$git_branch" ]; then
  printf "%b%s%b %s " "$(fg 239)" "$SEP_FULL" "$(fg $C_GIT_FG)" "$git_branch"
fi

if [ -n "$model" ]; then
  printf "%b%s%b%b %s %b" "$(fg 239)" "$SEP_FULL" "$(dim)" "$(fg $C_MDL_FG)" "$model" "$(rst)"
fi

# ── INLINE STATS (context, rate limits, latency, PR) ─────────────────────────
has_stat=0

# Context window — colored percentage dot
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  uc=$(usage_color "$used_int")
  [ "$has_stat" -eq 1 ] && inline_sep
  printf "%b%b● %s%%%b" "$(dim)" "$(fg $uc)" "$used_int" "$(rst)"
  has_stat=1
fi

# 5-hour rate limit
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  uc=$(usage_color "$five_int")
  reset_label=""
  if [ -n "$five_resets_at" ]; then
    reset_time=$(date -r "$five_resets_at" +"%H:%M" 2>/dev/null)
    [ -n "$reset_time" ] && reset_label=" $(dim)$(fg 239)↺${reset_time}$(rst)"
  fi
  [ "$has_stat" -eq 1 ] && inline_sep
  printf "%b%b5h %s%%%s%b" "$(dim)" "$(fg $uc)" "$five_int" "$reset_label" "$(rst)"
  has_stat=1
fi

# 7-day rate limit
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct")
  uc=$(usage_color "$week_int")
  week_reset_label=""
  if [ -n "$week_resets_at" ]; then
    week_reset_time=$(date -r "$week_resets_at" +"%a %H:%M" 2>/dev/null)
    [ -n "$week_reset_time" ] && week_reset_label=" $(dim)$(fg 239)↺${week_reset_time}$(rst)"
  fi
  [ "$has_stat" -eq 1 ] && inline_sep
  printf "%b%b7d %s%%%s%b" "$(dim)" "$(fg $uc)" "$week_int" "$week_reset_label" "$(rst)"
  has_stat=1
fi

# Latency
if claude_latency_read; then
  case "$CLAUDE_LATENCY_LEVEL" in
    normal)      _lc=82  ;;
    warn)        _lc=226 ;;
    peak)        _lc=196 ;;
    unavailable) _lc=239 ;;
    *)           _lc=244 ;;
  esac
  [ "$has_stat" -eq 1 ] && inline_sep
  if [ -n "$CLAUDE_LATENCY_MS" ] && [ "$CLAUDE_LATENCY_MS" != "null" ]; then
    printf "%b%b%s %sms%b" "$(dim)" "$(fg $_lc)" "$CLAUDE_LATENCY_ICON" "$CLAUDE_LATENCY_MS" "$(rst)"
  else
    printf "%b%b%s%b" "$(dim)" "$(fg $_lc)" "$CLAUDE_LATENCY_ICON" "$(rst)"
  fi
  has_stat=1
fi

# PR info
if [ -n "$pr_number" ]; then
  case "$pr_state" in
    approved)          _pr_color=82  ; _pr_icon=" " ;;
    changes_requested) _pr_color=196 ; _pr_icon=" " ;;
    draft)             _pr_color=244 ; _pr_icon=" " ;;
    *)                 _pr_color=75  ; _pr_icon=" " ;;
  esac
  [ "$has_stat" -eq 1 ] && inline_sep
  printf "%b%b%sPR #%s%b" "$(dim)" "$(fg $_pr_color)" "$_pr_icon" "$pr_number" "$(rst)"
  if [ -n "$pr_state" ] && [ "$pr_state" != "null" ]; then
    printf "%b %s%b" "$(dim)$(fg 239)" "$pr_state" "$(rst)"
  fi
  has_stat=1
fi

printf "\033[0m\n"
