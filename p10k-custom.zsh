# p10k-custom.zsh
# Custom Powerlevel10k overrides — sourced at the end of ~/.p10k.zsh
# Add all p10k customizations here so they are version-controlled and
# automatically applied on any machine after pulling this repo.
#
# Setup (one-time per machine): add this line to the END of ~/.p10k.zsh:
#   [[ -f ~/.oh-my-zsh/custom/p10k-custom.zsh ]] && source ~/.oh-my-zsh/custom/p10k-custom.zsh

# --- claude_latency segment ---
# Appends the Claude API latency indicator to the right prompt.
# Requires the claude-status plugin (plugins/claude-status/).
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(claude_latency)
