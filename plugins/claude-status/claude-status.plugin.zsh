# claude-status plugin
# Syncs the statusline script and auto-installs the launchd latency sampler.

_claude_status_dir="${0:A:h}"
_claude_plist_label="com.giorgiosaud.claude.latency"
_claude_plist_dest="$HOME/Library/LaunchAgents/com.giorgiosaud.claude.latency.plist"
_claude_plist_src="$_claude_status_dir/com.giorgiosaud.claude.latency.plist"
_claude_sampler="$_claude_status_dir/latency-sampler.sh"
_claude_settings="$HOME/.claude/settings.json"
# All init is silent to avoid triggering p10k instant prompt warnings
{
  mkdir -p "$HOME/.claude"
  chmod +x "$_claude_status_dir/statusline.sh"

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

} &>/dev/null

# User-callable function to register Claude Code statusline
function claude-status-register() {
  local settings="$HOME/.claude/settings.json"
  local cmd="bash ${0:A:h}/statusline.sh"
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: brew install jq"
    return 1
  fi
  mkdir -p "$HOME/.claude"
  [[ -f "$settings" ]] || echo '{}' > "$settings"
  jq --arg cmd "$cmd" '.statusLine = {"type":"command","command":$cmd}' \
    "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
  echo "Claude Code statusline registered. Restart Claude Code to apply."
}

unset _claude_status_dir _claude_plist_label _claude_plist_dest \
      _claude_plist_src _claude_sampler

# --- Powerlevel10k custom segment: claude_latency ---

source "${0:A:h}/latency-common.sh"

function prompt_claude_latency() {
  claude_latency_read || return

  local fg
  case "$CLAUDE_LATENCY_LEVEL" in
    normal)      fg=76  ;;   # green  (matches VCS_CLEAN)
    warn)        fg=178 ;;   # yellow (matches VCS_MODIFIED)
    peak)        fg=160 ;;   # red    (matches STATUS_ERROR)
    unavailable) fg=66  ;;   # grey   (matches TIME)
  esac

  if [[ -n "$CLAUDE_LATENCY_MS" && "$CLAUDE_LATENCY_MS" != "null" ]]; then
    p10k segment -f $fg -i "$CLAUDE_LATENCY_ICON" -t "${CLAUDE_LATENCY_MS}ms"
  else
    p10k segment -f $fg -i "$CLAUDE_LATENCY_ICON"
  fi
}

# Auto-register segment after p10k initializes (no manual .p10k.zsh edit needed)
function _claude_status_register() {
  if (( ${#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS} )); then
    if [[ ${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(Ie)claude_latency]} -eq 0 ]]; then
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(claude_latency)
    fi
    add-zsh-hook -d precmd _claude_status_register
    unfunction _claude_status_register
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _claude_status_register
