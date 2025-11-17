# Lazy Version Managers
# Defers initialization of version managers until first use
# Saves ~100-200ms on shell startup

# Lazy rbenv
if command -v rbenv &> /dev/null; then
  rbenv() {
    unfunction rbenv
    eval "$(command rbenv init -)"
    rbenv "$@"
  }
fi

# Lazy pyenv
if command -v pyenv &> /dev/null; then
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# Lazy rvm (if not already initialized by paths)
if [[ -s "$HOME/.rvm/scripts/rvm" ]] && ! command -v rvm &> /dev/null; then
  rvm() {
    unfunction rvm
    source "$HOME/.rvm/scripts/rvm"
    rvm "$@"
  }
fi
