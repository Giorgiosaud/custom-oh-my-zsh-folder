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
