# PATH Management Plugin
# Centralizes all PATH additions for development tools
# Organized by: local bins, language-specific tools, version managers, and specialized tools

# Performance: Cache directory checks
typeset -gA _dir_cache
_has_dir() {
  if [[ -z ${_dir_cache[$1]} ]]; then
    _dir_cache[$1]=$([[ -d $1 ]] && echo 1 || echo 0)
  fi
  return $(( ! _dir_cache[$1] ))
}

# Local binaries
_has_dir ~/.local/bin && export PATH=$PATH:~/.local/bin

# Project-specific bins (relative paths)
_has_dir ./node_modules/.bin && export PATH=$PATH:./node_modules/.bin
_has_dir ./vendor/bin && export PATH=$PATH:./vendor/bin

# Development tools
_has_dir ~/Project/sonar-bin/bin && export PATH=$PATH:~/Project/sonar-bin/bin
_has_dir /usr/local/sbin && export PATH=$PATH:/usr/local/sbin

# Version managers
_has_dir ~/.pyenv/shims && export PATH=$PATH:~/.pyenv/shims
_has_dir ~/.rvm/bin && export PATH=$PATH:~/.rvm/bin
_has_dir ~/.bun/bin && export PATH=$PATH:~/.bun/bin
_has_dir ~/.console-ninja/.bin && export PATH=$PATH:~/.console-ninja/.bin
_has_dir ~/.amplify/bin && export PATH=$PATH:~/.amplify/bin

# Specialized tools and databases
_has_dir /usr/local/opt/elasticsearch@2.4/bin && export PATH=$PATH:/usr/local/opt/elasticsearch@2.4/bin
_has_dir /usr/local/opt/openssl@1.1/bin && export PATH=$PATH:/usr/local/opt/openssl@1.1/bin

# Bun JavaScript runtime
if _has_dir "$BUN_INSTALL/bin"; then
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "~/.bun/_bun" ] && source "~/.bun/_bun"
fi

# Ruby Version Manager (RVM)
if _has_dir ~/.rvm/bin; then
  export PATH=$PATH:~/.rvm/bin
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
fi

# FNM (Fast Node Manager)
_has_dir "$FNM_PATH" && eval "$(fnm env --use-on-cd --shell zsh)"

# Load custom aliases
if [ -f ~/.oh-my-zsh/custom/aliases ]; then
  source ~/.oh-my-zsh/custom/aliases
fi
