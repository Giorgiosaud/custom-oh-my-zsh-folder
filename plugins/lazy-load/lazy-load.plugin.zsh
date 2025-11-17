# Lazy-loading plugin for heavy zsh plugins
# This improves shell startup time by deferring plugin loading

# Lazy load zsh-syntax-highlighting
# Only load when the prompt is about to be displayed
function _lazy_load_syntax_highlighting() {
  if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi

  # Remove the hook after loading
  add-zsh-hook -d precmd _lazy_load_syntax_highlighting
}

# Lazy load zsh-autosuggestions
# Only load when the prompt is about to be displayed
function _lazy_load_autosuggestions() {
  if [[ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  # Remove the hook after loading
  add-zsh-hook -d precmd _lazy_load_autosuggestions
}

# Schedule lazy loading on next prompt display
add-zsh-hook precmd _lazy_load_syntax_highlighting
add-zsh-hook precmd _lazy_load_autosuggestions
