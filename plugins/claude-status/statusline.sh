#!/usr/bin/env bash
# Claude Code statusline — single-line compact layout.
# ASCII separators and labels only: powerline / Nerd Font glyphs make iTerm2
# miscount widths. Colors are tuned for dark themes (no "dim": on a dark
# background it turns greys nearly invisible).

# Numbers come as "42.6"; a locale with a decimal comma would reject them
# (LC_ALL, not LC_NUMERIC: a user-set LC_ALL would override the latter). Output
# is ASCII and day names stay English.
export LC_ALL=C

source "$(dirname "$0")/latency-common.sh"

# ── Input: one jq call, fields split on the unit separator (\x1f) ────────────
# (not tabs: read collapses consecutive whitespace delimiters, which would
# shift every field after an empty one).
IFS=$'\x1f' read -r cwd model pr_number pr_state used_pct five_pct five_resets_at week_pct week_resets_at < <(
  jq -r '[
      (.workspace.current_dir // .cwd // ""),
      (.model.display_name // ""),
      (.pr.number // ""),
      (.pr.review_state // ""),
      (.context_window.used_percentage // ""),
      (.rate_limits.five_hour.used_percentage // ""),
      (.rate_limits.five_hour.resets_at // ""),
      (.rate_limits.seven_day.used_percentage // ""),
      (.rate_limits.seven_day.resets_at // "")
    ] | map(tostring) | join("\u001f")'
)

short_cwd=$(basename "$cwd")
[ -z "$short_cwd" ] && short_cwd="/"

# ── Git: branch and dirty flag from a single status call ─────────────────────
git_branch=""
git_dirty=""
if status=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  git_branch=$(sed -n 's/^# branch\.head //p' <<<"$status")
  if [ "$git_branch" = "(detached)" ]; then
    git_branch=$(sed -n 's/^# branch\.oid \(.\{7\}\).*/\1/p' <<<"$status")
  fi
  grep -qv '^#' <<<"$status" && git_dirty="*"
fi

# ── Palette (256 colors, readable on dark backgrounds) ───────────────────────
C_PATH=252     # light grey
C_GIT=114      # soft green
C_DIRTY=215    # orange
C_MODEL=146    # muted lavender
C_SEP=243      # separators
C_MUTED=246    # reset times, PR state
C_LABEL=250    # "ctx", "5h", "7d", "api"

fg()  { printf "\033[38;5;%sm" "$1"; }
rst() { printf "\033[0m"; }

# Usage color: green -> yellow -> orange -> red
usage_color() {
  local pct=$1
  if   [ "$pct" -lt 50 ]; then printf "114"
  elif [ "$pct" -lt 75 ]; then printf "221"
  elif [ "$pct" -lt 90 ]; then printf "208"
  else                          printf "203"
  fi
}

sep()      { printf "%b | %b" "$(fg $C_SEP)" "$(rst)"; }
stat_sep() { printf "%b : %b" "$(fg $C_SEP)" "$(rst)"; }

# ── Segments ─────────────────────────────────────────────────────────────────
printf "%b %s%b" "$(fg $C_PATH)" "$short_cwd" "$(rst)"

if [ -n "$git_branch" ]; then
  sep
  printf "%b%s%b" "$(fg $C_GIT)" "$git_branch" "$(rst)"
  [ -n "$git_dirty" ] && printf "%b%s%b" "$(fg $C_DIRTY)" "$git_dirty" "$(rst)"
fi

if [ -n "$model" ]; then
  sep
  printf "%b%s%b" "$(fg $C_MODEL)" "${model#claude-}" "$(rst)"
fi

# ── Stats: context, rate limits, latency, PR ─────────────────────────────────
has_stat=0
next_stat() {
  if [ "$has_stat" -eq 1 ]; then stat_sep; else sep; fi
  has_stat=1
}

# pct_stat <label> <percentage> <reset epoch> <date format>
pct_stat() {
  local label=$1 pct=$2 resets_at=$3 fmt=$4 int color reset=""
  int=$(printf "%.0f" "$pct" 2>/dev/null) || return
  color=$(usage_color "$int")
  if [ -n "$resets_at" ]; then
    reset=$(date -r "${resets_at%.*}" +"$fmt" 2>/dev/null)
  fi
  next_stat
  [ -n "$label" ] && printf "%b%s " "$(fg $C_LABEL)" "$label"
  printf "%b%s%%%b" "$(fg "$color")" "$int" "$(rst)"
  [ -n "$reset" ] && printf " %b@%s%b" "$(fg $C_MUTED)" "$reset" "$(rst)"
}

[ -n "$used_pct" ]  && pct_stat "ctx" "$used_pct"  ""                ""
[ -n "$five_pct" ]  && pct_stat "5h"  "$five_pct"  "$five_resets_at" "%H:%M"
[ -n "$week_pct" ]  && pct_stat "7d"  "$week_pct"  "$week_resets_at" "%a %H:%M"

# Latency (see latency-common.sh). "api !" in red: the sampler keeps failing or
# stopped; check ~/.claude/latency-sampler.log.
if claude_latency_read; then
  case "$CLAUDE_LATENCY_LEVEL" in
    normal) _lc=114 ;;
    warn)   _lc=221 ;;
    peak)   _lc=203 ;;
    *)      _lc=$C_MUTED ;;
  esac
  next_stat
  printf "%bapi " "$(fg $C_LABEL)"
  if [ "$CLAUDE_LATENCY_LEVEL" = "error" ]; then
    printf "%b!%b" "$(fg 196)" "$(rst)"
  elif [ -n "$CLAUDE_LATENCY_MS" ] && [ "$CLAUDE_LATENCY_MS" != "null" ]; then
    printf "%b%sms%b" "$(fg $_lc)" "$CLAUDE_LATENCY_MS" "$(rst)"
  else
    printf "%b?%b" "$(fg $_lc)" "$(rst)"
  fi
fi

# PR
if [ -n "$pr_number" ]; then
  case "$pr_state" in
    approved)          _pc=114 ;;
    changes_requested) _pc=203 ;;
    draft)             _pc=$C_MUTED ;;
    *)                 _pc=111 ;;
  esac
  next_stat
  printf "%bPR #%s%b" "$(fg $_pc)" "$pr_number" "$(rst)"
  [ -n "$pr_state" ] && printf " %b%s%b" "$(fg $C_MUTED)" "${pr_state//_/ }" "$(rst)"
fi

printf "\033[0m\n"
