# PATH Management Plugin
# Centralizes all PATH additions for development tools
# Organized by: local bins, language-specific tools, version managers, and specialized tools

# Local binaries
if [ -d ~/.local/bin ]; then
export PATH=$PATH:~/.local/bin
fi
if [ -d ~/.composer/vendor/bin ]; then
export PATH=$PATH:~/.composer/vendor/bin
fi

# Project-specific bins (relative paths)
if [ -d ./node_modules/.bin ]; then
export PATH=$PATH:./node_modules/.bin
fi
if [ -d ./vendor/bin ]; then
export PATH=$PATH:./vendor/bin
fi

# Development tools
if [ -d ~/Project/sonar-bin/bin ]; then
export PATH=$PATH:~/Project/sonar-bin/bin
fi
if [ -d /usr/local/sbin ]; then
export PATH=$PATH:/usr/local/sbin
fi
# Version managers
if [ -d ~/.pyenv/shims ]; then
export PATH=$PATH:~/.pyenv/shims
fi
if [ -d ~/.rvm/scripts/rvm ]; then
export PATH=$PATH:~/.rvm/bin
fi
if [ -d ~/.bun/bin ]; then
export PATH=$PATH:~/.bun/bin
fi
if [ -d ~/.console-ninja/.bin ]; then
export PATH=$PATH:~/.console-ninja/.bin
fi
if [ -d ~/.amplify/bin ]; then
export PATH=$PATH:~/.amplify/bin
fi
# FNM configuration moved to envs plugin
# Specialized tools and databases
if [ -d /usr/local/opt/elasticsearch@2.4/bin ]; then
export PATH=$PATH:/usr/local/opt/elasticsearch@2.4/bin
fi
if [ -d /usr/local/opt/openssl@1.1/bin ]; then
export PATH=$PATH:/usr/local/opt/openssl@1.1/bin
fi
# Bun JavaScript runtime
if [ -d "$BUN_INSTALL/bin" ]; then
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"
fi

# Ruby Version Manager (RVM)
if [ -d ~/.rvm/bin ]; then
export PATH=$PATH:~/.rvm/bin #UNCOMMENTED
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
fi
# Fnm

if [ -d "$FNM_PATH" ]; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
