# Smart Package Manager
# Auto-detects and uses the correct package manager based on lockfile
# Supports: npm, yarn, pnpm, bun

# Detect package manager from lockfile
_detect_package_manager() {
  if [[ -f bun.lockb ]]; then
    echo "bun"
  elif [[ -f pnpm-lock.yaml ]]; then
    echo "pnpm"
  elif [[ -f yarn.lock ]]; then
    echo "yarn"
  elif [[ -f package-lock.json ]]; then
    echo "npm"
  else
    echo "npm"  # Default to npm
  fi
}

# Smart npm wrapper
npm() {
  local pm=$(_detect_package_manager)

  if [[ "$pm" != "npm" ]]; then
    echo "→ Using $pm (detected from lockfile)"
    command $pm "$@"
  else
    command npm "$@"
  fi
}

# Smart package manager aliases
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias ns='npm start'

# Show which package manager is detected
which-pm() {
  local pm=$(_detect_package_manager)
  echo "Package manager: $pm"

  if command -v $pm &> /dev/null; then
    echo "Version: $(command $pm --version | head -1)"
  else
    echo "⚠️  $pm is not installed"
  fi
}

# Project info
project-info() {
  if [[ ! -f package.json ]]; then
    echo "✗ Not a Node.js project (no package.json)"
    return 1
  fi

  echo "Project: $(node -p "require('./package.json').name || 'unnamed'")"
  echo "Version: $(node -p "require('./package.json').version || 'n/a'")"
  echo "Node: $(node -v 2>/dev/null || echo 'not found')"
  echo "Package Manager: $(_detect_package_manager)"

  # Check for scripts
  local scripts=$(node -p "Object.keys(require('./package.json').scripts || {}).join(', ')" 2>/dev/null)
  if [[ -n "$scripts" && "$scripts" != "undefined" ]]; then
    echo "Scripts: $scripts"
  fi
}
