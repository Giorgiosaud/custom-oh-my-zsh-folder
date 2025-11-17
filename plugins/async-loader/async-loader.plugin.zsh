# Async Plugin Loader
# Loads non-critical plugins in background for faster shell startup

# Load non-critical plugins asynchronously
{
  # FZF integration (nice to have, not critical)
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Node modules optimize (utility, rarely used on startup)
  [ -f $ZSH_CUSTOM/plugins/node-modules-optimize/node-modules-optimize.plugin.zsh ] && \
    source $ZSH_CUSTOM/plugins/node-modules-optimize/node-modules-optimize.plugin.zsh

} &!
