# claude-status plugin
# Syncs the statusline script and auto-installs the launchd latency sampler.

_claude_status_dir="${0:A:h}"
_claude_plist_label="com.claude.latency"
_claude_plist_dest="$HOME/Library/LaunchAgents/com.claude.latency.plist"
_claude_plist_src="$_claude_status_dir/com.claude.latency.plist"
_claude_sampler="$_claude_status_dir/latency-sampler.sh"
_claude_statusline_dest="$HOME/.claude/statusline-command.sh"

mkdir -p "$HOME/.claude"

# Sync statusline script
cp "$_claude_status_dir/statusline.sh" "$_claude_statusline_dest"
chmod +x "$_claude_statusline_dest"

# Render and install launchd plist (idempotent)
sed \
  -e "s|__SAMPLER_PATH__|$_claude_sampler|g" \
  -e "s|__HOME__|$HOME|g" \
  "$_claude_plist_src" > "$_claude_plist_dest"

if ! launchctl list "$_claude_plist_label" &>/dev/null; then
  launchctl bootstrap "gui/$(id -u)" "$_claude_plist_dest" 2>/dev/null \
    || launchctl load "$_claude_plist_dest" 2>/dev/null \
    || true
fi

unset _claude_status_dir _claude_plist_label _claude_plist_dest \
      _claude_plist_src _claude_sampler _claude_statusline_dest

# --- Powerlevel10k custom segment: claude_latency ---

function prompt_claude_latency() {
  local cache="$HOME/.claude/latency_cache.json"
  [[ -f "$cache" ]] || return

  local level ms icon color
  level=$(jq -r '.level // "normal"' "$cache" 2>/dev/null) || return
  ms=$(jq -r '.ms // ""' "$cache" 2>/dev/null)

  local icon fg bg text
  case "$level" in
    normal)      icon=$'\uf0e7'; fg=0; bg=2 ;;   # black on green
    warn)        icon=$'\uf071'; fg=0; bg=3 ;;   # black on yellow
    peak)        icon=$'\uf21e'; fg=0; bg=1 ;;   # black on red
    unavailable) icon=$'\ufba4'; fg=0; bg=7 ;;   # black on grey
    *)           return ;;
  esac

  if [[ -n "$ms" && "$ms" != "null" ]]; then
    p10k segment -b $bg -f $fg -i "$icon" -t "${ms}ms"
  else
    p10k segment -b $bg -f $fg -i "$icon"
  fi
}
