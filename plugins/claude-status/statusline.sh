#!/usr/bin/env bash
# Claude Code statusline — plain Unicode separators, polished two-line layout

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

user=$(whoami)
host=$(hostname -s)

# Path: relative to project parent, or home-abbreviated
if [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
  project_parent=$(dirname "$project_dir")
  short_cwd="${cwd/#$project_parent\//}"
else
  short_cwd="${cwd/#$HOME/~}"
fi

git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# ── ANSI helpers ─────────────────────────────────────────────────────────────
fg()  { printf "\033[38;5;%sm" "$1"; }
bg()  { printf "\033[48;5;%sm" "$1"; }
bold(){ printf "\033[1m"; }
dim() { printf "\033[2m"; }
rst() { printf "\033[0m"; }

# Separators — Nerd Font lego separator thin
SEP_FULL=   # U+E0CF nerd font lego separator thin
SEP_THIN=   # U+E0CF nerd font lego separator thin

# Palette
C_HOST_BG=24    # dark teal
C_HOST_FG=195   # bright near-white
C_PATH_BG=238   # dark grey
C_PATH_FG=252   # light grey
C_GIT_BG=22     # dark green
C_GIT_FG=157    # bright mint
C_MDL_BG=235    # near-black
C_MDL_FG=244    # medium grey
C_L2_FG=245     # muted grey

# Usage gradient: green -> yellow -> orange -> red
bar_color() {
  local pct=$1
  if   [ "$pct" -lt 50 ]; then printf "82"
  elif [ "$pct" -lt 75 ]; then printf "226"
  elif [ "$pct" -lt 90 ]; then printf "208"
  else                          printf "196"
  fi
}

make_bar() {
  local pct=$1 width=8
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar="" i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}▒"; done
  printf "%s" "$bar"
}

# ── LINE 1 ───────────────────────────────────────────────────────────────────
# Segment: user@host
printf "%b%b%b %s@%s " "$(bold)" "$(bg $C_HOST_BG)" "$(fg $C_HOST_FG)" "$user" "$host"

# Transition host -> path
printf "%b%b%b %s %b" "$(rst)" "$(bg $C_PATH_BG)" "$(fg $C_HOST_BG)" "$SEP_FULL" "$(rst)"

# Segment: cwd
printf "%b%b  %s " "$(bg $C_PATH_BG)" "$(fg $C_PATH_FG)" "$short_cwd"

if [ -n "$git_branch" ]; then
  printf "%b%b%b %s %b" "$(rst)" "$(bg $C_GIT_BG)" "$(fg $C_PATH_BG)" "$SEP_FULL" "$(rst)"
  printf "%b%b  %s " "$(bg $C_GIT_BG)" "$(fg $C_GIT_FG)" "$git_branch"
  _prev_bg=$C_GIT_BG
else
  _prev_bg=$C_PATH_BG
fi

if [ -n "$model" ]; then
  printf "%b%b%b %s %b" "$(rst)" "$(bg $C_MDL_BG)" "$(fg $_prev_bg)" "$SEP_FULL" "$(rst)"
  printf "%b%b%b  %s " "$(dim)" "$(bg $C_MDL_BG)" "$(fg $C_MDL_FG)" "$model"
  printf "%b%b %s %b" "$(rst)" "$(fg $C_MDL_BG)" "$SEP_FULL" "$(rst)"
else
  printf "%b%b %s %b" "$(rst)" "$(fg $_prev_bg)" "$SEP_FULL" "$(rst)"
fi

printf "\033[0m\n"

# ── LINE 2 ───────────────────────────────────────────────────────────────────
has_l2=0

l2_sep() {
  printf "%b %s %b" "$(fg 239)" "$SEP_THIN" "$(fg $C_L2_FG)"
}

# Context window
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar=$(make_bar "$used_int")
  bc=$(bar_color "$used_int")
  printf " %b%b %b%b%s%b %b%s%%%b" \
    "$(rst)$(dim)" "$(fg 67)" \
    "$(rst)$(dim)" "$(fg $bc)" "$bar" "$(rst)$(dim)" \
    "$(fg $C_L2_FG)" "$used_int" "$(rst)"
  has_l2=1
fi

# 5-hour rate limit
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  bar=$(make_bar "$five_int")
  bc=$(bar_color "$five_int")
  reset_label=""
  if [ -n "$five_resets_at" ]; then
    reset_time=$(date -r "$five_resets_at" +"%H:%M" 2>/dev/null)
    [ -n "$reset_time" ] && reset_label=" $(rst)$(dim)$(fg 239)rst ${reset_time}$(rst)"
  fi
  [ "$has_l2" -eq 1 ] && l2_sep
  printf "%b%b 5h %b%b%s%b %b%s%%%s%b" \
    "$(rst)$(dim)" "$(fg 67)" \
    "$(rst)$(dim)" "$(fg $bc)" "$bar" "$(rst)$(dim)" \
    "$(fg $C_L2_FG)" "$five_int" "$reset_label" "$(rst)"
  has_l2=1
fi

# 7-day rate limit
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct")
  bar=$(make_bar "$week_int")
  bc=$(bar_color "$week_int")
  week_reset_label=""
  if [ -n "$week_resets_at" ]; then
    week_reset_time=$(date -r "$week_resets_at" +"%a %H:%M" 2>/dev/null)
    [ -n "$week_reset_time" ] && week_reset_label=" $(rst)$(dim)$(fg 239)rst ${week_reset_time}$(rst)"
  fi
  [ "$has_l2" -eq 1 ] && l2_sep
  printf "%b%b 7d %b%b%s%b %b%s%%%s%b" \
    "$(rst)$(dim)" "$(fg 67)" \
    "$(rst)$(dim)" "$(fg $bc)" "$bar" "$(rst)$(dim)" \
    "$(fg $C_L2_FG)" "$week_int" "$week_reset_label" "$(rst)"
  has_l2=1
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
  [ "$has_l2" -eq 1 ] && l2_sep
  if [ -n "$CLAUDE_LATENCY_MS" ] && [ "$CLAUDE_LATENCY_MS" != "null" ]; then
    printf "%b%b%s %s%bms%b" \
      "$(rst)$(dim)" "$(fg $_lc)" "$CLAUDE_LATENCY_ICON" "$CLAUDE_LATENCY_MS" \
      "$(fg $C_L2_FG)" "$(rst)"
  else
    printf "%b%b%s%b" "$(rst)$(dim)" "$(fg $_lc)" "$CLAUDE_LATENCY_ICON" "$(rst)"
  fi
  has_l2=1
fi

# PR info
if [ -n "$pr_number" ]; then
  case "$pr_state" in
    approved)          _pr_color=82  ; _pr_icon=" " ;;
    changes_requested) _pr_color=196 ; _pr_icon=" " ;;
    draft)             _pr_color=244 ; _pr_icon=" " ;;
    *)                 _pr_color=75  ; _pr_icon=" " ;;
  esac
  [ "$has_l2" -eq 1 ] && l2_sep
  printf "%b%b%sPR #%s%b" \
    "$(rst)$(dim)" "$(fg $_pr_color)" "$_pr_icon" "$pr_number" "$(rst)"
  if [ -n "$pr_state" ] && [ "$pr_state" != "null" ]; then
    printf "%b %s%b" "$(dim)$(fg 239)" "$pr_state" "$(rst)"
  fi
  has_l2=1
fi

if [ "$has_l2" -eq 1 ]; then
  printf " %b\n" "$(rst)"
else
  printf "%b\n" "$(rst)"
fi
