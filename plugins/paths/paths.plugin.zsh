# PATH Management Plugin
# Centralizes all PATH additions for development tools

# 1. Performance: Cache directory checks
typeset -gA _dir_cache
_has_dir() {
  if [[ -z ${_dir_cache[$1]} ]]; then
    _dir_cache[$1]=$([[ -d $1 ]] && echo 1 || echo 0)
  fi
  return $(( ! _dir_cache[$1] ))
}

# 2. Entorno básico y herramientas críticas (Van al INICIO del PATH)
# Homebrew (Corregido de -f a -d)
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# Local bins del usuario
_has_dir ~/.local/bin && export PATH="~/.local/bin:$PATH"


# 3. Runtimes y Version Managers
# Bun
export BUN_INSTALL="$HOME/.bun"
if _has_dir "$BUN_INSTALL/bin"; then
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# FNM (Fast Node Manager)
# Si usas FNM, usualmente se inicializa directo. Si requiere FNM_PATH, asegúrate de definirla antes.
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Pyenv & Ruby/RVM
_has_dir ~/.pyenv/shims && export PATH="$HOME/.pyenv/shims:$PATH"

if _has_dir ~/.rvm/bin; then
  export PATH="$PATH:$HOME/.rvm/bin"
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
fi

# Java (Corretto)
if _has_dir "$HOME/Library/Java/JavaVirtualMachines/corretto-17.0.17/Contents/Home"; then
  export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/corretto-17.0.17/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi


# 4. Herramientas secundarias y específicas (Al final del PATH)
_has_dir /usr/local/sbin && export PATH="$PATH:/usr/local/sbin"
_has_dir ~/.console-ninja/.bin && export PATH="$PATH:~/.console-ninja/.bin"
_has_dir ~/.amplify/bin && export PATH="$PATH:~/.amplify/bin"
_has_dir ~/Project/sonar-bin/bin && export PATH="$PATH:~/Project/sonar-bin/bin"

# Bases de datos / Legacy de Intel (vía usr/local)
_has_dir /usr/local/opt/elasticsearch@2.4/bin && export PATH="$PATH:/usr/local/opt/elasticsearch@2.4/bin"
_has_dir /usr/local/opt/openssl@1.1/bin && export PATH="$PATH:/usr/local/opt/openssl@1.1/bin"


# 5. Configuraciones de Zsh, Autocomplete y Aliases
# Cargar aliases personalizados
[[ -f ~/.oh-my-zsh/custom/aliases ]] && source ~/.oh-my-zsh/custom/aliases

# Completions y Zstyle
fpath+=~/.zfunc
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select