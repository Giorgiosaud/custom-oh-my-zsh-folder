# Future Improvement Opportunities

Potential optimizations and enhancements for the Zsh configuration.

---

## Performance Optimizations

### 1. Further Lazy-Loading

**Current State**: zsh-autosuggestions and zsh-syntax-highlighting are lazy-loaded

**Opportunities**:
- **zsh-vi-mode**: Could be deferred if not used immediately
  - Savings: ~50-100ms
  - Trade-off: Vi keybindings available after first prompt

- **Version Manager Initialization**: Defer rbenv/rvm/pyenv until needed
  - Savings: ~100-200ms
  - Implementation: Load on first use of `ruby`, `python`, etc.
  - Risk: Commands unavailable until triggered

**Example Implementation**:
```bash
# Lazy rbenv
rbenv() {
  unfunction rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}
```

### 2. Async Plugin Loading

**Concept**: Load non-critical plugins in background

**Benefits**:
- Shell prompt appears faster
- Plugins load while user reads prompt
- No functional impact

**Implementation Options**:
- Use `zsh-async` library
- Fork plugin loading to background process
- Load after first command execution

**Candidates for Async Loading**:
- `node-modules-optimize` (rarely used on startup)
- `reset-intelij` (utility, not critical)
- FZF integration (can load after prompt)

**Example**:
```bash
# Load non-critical plugins async
{
  source ~/.oh-my-zsh/custom/plugins/node-modules-optimize/plugin.zsh
  source ~/.fzf.zsh
} &!
```

### 3. Conditional Plugin Loading

**Concept**: Only load plugins when relevant

**Strategies**:
- **Project Detection**: Load Laravel aliases only in Laravel projects
- **Tool Detection**: Load version managers only if tools installed
- **Directory-Based**: Load project-specific configs

**Implementation**:
```bash
# Load Laravel aliases only in Laravel projects
if [[ -f "artisan" ]]; then
  source ~/.oh-my-zsh/custom/plugins/laravel-aliases/plugin.zsh
fi

# Load Docker plugins only if Docker installed
if command -v docker &> /dev/null; then
  source ~/.oh-my-zsh/custom/plugins/docker/plugin.zsh
fi
```

**Benefits**:
- Faster startup in non-Laravel projects
- Less memory usage
- Cleaner namespace (fewer aliases)

### 4. Completion Cache

**Current State**: Completions regenerated each session

**Opportunity**: Cache completion files

**Implementation**:
```bash
# Enable completion cache
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
```

**Benefits**:
- 50-100ms faster startup
- Completions only rebuild once per day
- No functional impact

### 5. Command Caching

**Concept**: Cache expensive checks

**Examples**:
```bash
# Cache which checks
typeset -A _command_cache
has_command() {
  if [[ -z ${_command_cache[$1]} ]]; then
    _command_cache[$1]=$(command -v $1 &>/dev/null && echo 1 || echo 0)
  fi
  return $(( ! _command_cache[$1] ))
}

# Cache directory checks
typeset -A _dir_cache
has_directory() {
  if [[ -z ${_dir_cache[$1]} ]]; then
    _dir_cache[$1]=$([[ -d $1 ]] && echo 1 || echo 0)
  fi
  return $(( ! _dir_cache[$1] ))
}
```

**Usage in paths plugin**:
```bash
if has_directory ~/.local/bin; then
  export PATH=$PATH:~/.local/bin
fi
```

---

## Organization & Modularity

### 6. Split Aliases by Topic

**Current State**: 60+ aliases in single file

**Proposal**: Topic-based files

**Structure**:
```
custom/plugins/aliases/
├── aliases.plugin.zsh    # Main plugin file
├── git.zsh              # Git aliases
├── laravel.zsh          # Laravel/PHP
├── modyo.zsh            # Modyo CLI
├── system.zsh           # System utilities
└── functions.zsh        # Custom functions
```

**Plugin File**:
```bash
# aliases.plugin.zsh
source ${0:A:h}/git.zsh
source ${0:A:h}/laravel.zsh
source ${0:A:h}/modyo.zsh
source ${0:A:h}/system.zsh
source ${0:A:h}/functions.zsh
```

**Benefits**:
- Easier to maintain
- Can disable entire categories
- Better organization
- Easier to share specific topics

### 7. Plugin-ify Aliases

**Current State**: Aliases sourced from standalone file

**Proposal**: Convert to proper Oh My Zsh plugin

**Already Implemented**: Added to plugins list as `aliases`

**Next Steps**:
1. Create `plugins/aliases/aliases.plugin.zsh`
2. Move aliases file to plugin
3. Split into topic files (see #6)
4. Add plugin README

**Structure**:
```
custom/plugins/aliases/
├── aliases.plugin.zsh
├── README.md
├── git.zsh
├── laravel.zsh
├── modyo.zsh
├── system.zsh
└── functions.zsh
```

### 8. Environment-Specific Configs

**Concept**: Load different configs for different machines

**Use Cases**:
- Work vs personal machine
- Different project types
- Machine-specific tools

**Implementation**:
```bash
# In custom/zshrc
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# Or by hostname
if [[ -f ~/.oh-my-zsh/custom/hosts/$(hostname).zsh ]]; then
  source ~/.oh-my-zsh/custom/hosts/$(hostname).zsh
fi
```

**Example ~/.zshrc.local**:
```bash
# Work machine specific
export WORK_PROJECTS="$HOME/work"
export COMPANY_VPN="vpn.company.com"

# Work-specific aliases
alias work='cd $WORK_PROJECTS'
alias vpn='sudo openconnect $COMPANY_VPN'
```

---

## Feature Enhancements

### 9. Smart Secret Management

**Current State**: Manual secret storage

**Enhancements**:

**A. Secret Import/Export**:
```bash
# Export secrets to encrypted file
export-secrets() {
  local output="$HOME/.secrets-backup-$(date +%Y%m%d).gpg"
  list-secrets | gpg --encrypt --recipient $USER -o "$output"
  echo "Secrets exported to $output"
}

# Import from backup
import-secrets() {
  gpg --decrypt "$1" | while read secret; do
    put-secret "$secret" "$(get-secret-from-backup "$secret")"
  done
}
```

**B. Secret Validation**:
```bash
# Validate secret before use
validate-github-token() {
  local token=$(get-secret "github_token")
  if curl -s -H "Authorization: token $token" \
    https://api.github.com/user | grep -q login; then
    echo "✓ GitHub token valid"
  else
    echo "✗ GitHub token invalid or expired"
    return 1
  fi
}
```

**C. Secret Rotation Reminder**:
```bash
# Check secret age
check-secret-age() {
  local secret_date=$(security find-generic-password -a "$USER" \
    -s "$1" -w 2>/dev/null | date -r - +%s)
  local now=$(date +%s)
  local age=$(( (now - secret_date) / 86400 ))

  if [[ $age -gt 90 ]]; then
    echo "⚠️  Secret '$1' is $age days old. Consider rotating."
  fi
}
```

### 10. Plugin Manager

**Concept**: Manage third-party plugins easily

**Implementation**:
```bash
# plugin-manager.zsh
plugin-install() {
  local plugin_url="$1"
  local plugin_name=$(basename "$plugin_url" .git)
  git clone --depth=1 "$plugin_url" \
    "$ZSH_CUSTOM/plugins/$plugin_name"
}

plugin-update() {
  for plugin in $ZSH_CUSTOM/plugins/*/; do
    if [[ -d "$plugin/.git" ]]; then
      echo "Updating $(basename $plugin)..."
      (cd "$plugin" && git pull)
    fi
  done
}

plugin-remove() {
  rm -rf "$ZSH_CUSTOM/plugins/$1"
}
```

### 11. Project Templates

**Concept**: Quick project setup with templates

**Implementation**:
```bash
# Create project from template
new-project() {
  local template="$1"
  local name="$2"

  case $template in
    laravel)
      composer create-project laravel/laravel "$name"
      cd "$name"
      setup-laravel-env
      ;;
    node)
      mkdir "$name" && cd "$name"
      npm init -y
      setup-node-project
      ;;
    *)
      echo "Unknown template: $template"
      return 1
      ;;
  esac
}
```

### 12. Git Workflow Enhancements

**A. Smart Branch Switching**:
```bash
# Switch to branch with fuzzy search
gb() {
  git branch | fzf | xargs git checkout
}

# Create and switch to new branch
gcb() {
  local branch="$1"
  git checkout -b "$branch"
  git push -u origin "$branch"
}
```

**B. Better Commit Messages**:
```bash
# Commit with conventional commits format
gcommit() {
  local type="$1"
  local scope="$2"
  local message="$3"

  git commit -m "${type}(${scope}): ${message}"
}

# Interactive commit with template
gci() {
  local template=$(cat <<EOF
# Type: feat|fix|docs|style|refactor|test|chore
# Scope: component or file affected
# Subject: what changed

type(scope): subject

# Why this change?

# What changed?

# Breaking changes?
EOF
)
  echo "$template" | git commit -F -
}
```

---

## Tool Integration

### 13. Docker Enhancements

```bash
# Smart docker compose
dcu() {
  if [[ -f docker-compose.yml ]]; then
    docker-compose up -d "$@"
  else
    echo "No docker-compose.yml found"
    return 1
  fi
}

# Docker cleanup
docker-cleanup() {
  docker system prune -af --volumes
  echo "✓ Docker cleaned up"
}
```

### 14. Node.js Project Utilities

```bash
# Smart package manager detection
npm() {
  if [[ -f pnpm-lock.yaml ]]; then
    command pnpm "$@"
  elif [[ -f yarn.lock ]]; then
    command yarn "$@"
  elif [[ -f bun.lockb ]]; then
    command bun "$@"
  else
    command npm "$@"
  fi
}

# Project info
project-info() {
  echo "Project: $(jq -r .name package.json)"
  echo "Version: $(jq -r .version package.json)"
  echo "Node: $(node -v)"
  echo "Package Manager: $(detect-package-manager)"
}
```

### 15. Laravel Enhancements

```bash
# Smart artisan
art() {
  if [[ -f artisan ]]; then
    php artisan "$@"
  else
    echo "Not in a Laravel project"
    return 1
  fi
}

# Quick test
test() {
  if [[ -f phpunit.xml ]]; then
    ./vendor/bin/phpunit "$@"
  elif [[ -f composer.json ]] && grep -q pestphp composer.json; then
    ./vendor/bin/pest "$@"
  else
    echo "No test framework found"
    return 1
  fi
}
```

---

## Monitoring & Debugging

### 16. Startup Profiling

```bash
# Profile zsh startup
zsh-profile() {
  local profile_file="/tmp/zsh-profile-$$.log"

  PS4=$'%D{%M%S%.} %N:%i> ' zsh -x -i -c exit 2>&1 | \
    ts -i "%.s" > "$profile_file"

  echo "Profile saved to: $profile_file"
  echo "Slowest operations:"
  cat "$profile_file" | sort -k1 -n | tail -20
}

# Continuous profiling
zsh-benchmark() {
  local iterations=10
  local total=0

  for i in {1..$iterations}; do
    local time=$( { time zsh -i -c exit } 2>&1 | grep real | awk '{print $2}' )
    total=$(( total + time ))
    echo "Run $i: $time"
  done

  echo "Average: $(( total / iterations ))ms"
}
```

### 17. Plugin Status

```bash
# Show loaded plugins
plugins-loaded() {
  echo "Loaded plugins:"
  for plugin in $plugins; do
    echo "  ✓ $plugin"
  done
}

# Check plugin load times
plugins-benchmark() {
  for plugin in $plugins; do
    local start=$(($(date +%s%N)/1000000))
    source "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" 2>/dev/null
    local end=$(($(date +%s%N)/1000000))
    echo "$plugin: $((end-start))ms"
  done
}
```

---

## Documentation

### 18. Auto-Generated Plugin Docs

**Concept**: Generate README from plugin comments

```bash
# Generate plugin documentation
generate-plugin-docs() {
  local plugin="$1"
  local file="$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
  local readme="$ZSH_CUSTOM/plugins/$plugin/README.md"

  echo "# $(basename $plugin) Plugin" > "$readme"
  echo "" >> "$readme"
  grep -E "^#" "$file" | sed 's/^# //' >> "$readme"
}
```

### 19. Interactive Help

```bash
# Show all custom functions with descriptions
zsh-help() {
  echo "Custom Functions:"
  declare -F | awk '{print $3}' | grep -v "^_" | while read func; do
    local doc=$(type $func | grep -A 1 "^# " | tail -1 | sed 's/^# //')
    echo "  $func - $doc"
  done
}

# Search aliases
alias-search() {
  alias | grep -i "$1"
}
```

---

## Testing

### 20. Configuration Tests

```bash
# Test configuration validity
test-zshrc() {
  echo "Testing configuration..."

  # Test syntax
  if zsh -n ~/.oh-my-zsh/custom/zshrc; then
    echo "✓ Syntax valid"
  else
    echo "✗ Syntax errors found"
    return 1
  fi

  # Test plugins load
  local test_plugins=(${(@)plugins})
  for plugin in $test_plugins; do
    if [[ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]]; then
      echo "✓ $plugin plugin found"
    else
      echo "✗ $plugin plugin missing"
    fi
  done

  # Test secrets
  if get-secret "github_token" &>/dev/null; then
    echo "✓ GitHub token configured"
  else
    echo "⚠  GitHub token not in keychain"
  fi
}
```

---

## Priority Recommendations

### High Priority (Easy wins)
1. ✅ **Completion Cache** - 50-100ms savings, 5 minutes to implement
2. ✅ **Split Aliases** - Better organization, no performance cost
3. ✅ **Plugin-ify Aliases** - Already in plugins list, just needs structure

### Medium Priority (Good ROI)
4. **Async Plugin Loading** - 100-200ms savings, moderate complexity
5. **Command Caching** - 20-50ms savings, low risk
6. **Git Workflow Enhancements** - Quality of life improvements

### Low Priority (Nice to have)
7. **Version Manager Lazy Loading** - Complex, user impact
8. **Project Templates** - Convenience feature
9. **Monitoring Tools** - Debugging aid

### Research Required
10. **Conditional Plugin Loading** - Needs usage pattern analysis
11. **Environment-Specific Configs** - Needs use case validation

---

## Implementation Strategy

### Phase 1: Quick Wins (Week 1)
- Enable completion cache
- Split aliases into topic files
- Add command caching to paths plugin

### Phase 2: Organization (Week 2-3)
- Complete aliases plugin structure
- Add plugin README files
- Create minimal test suite

### Phase 3: Performance (Week 4-5)
- Implement async loading for non-critical plugins
- Profile and optimize slowest components
- Measure improvements

### Phase 4: Features (Ongoing)
- Add enhancements based on usage patterns
- Iterate on git workflow improvements
- Expand secret management features

---

## Notes

- All changes should maintain backward compatibility
- Performance improvements must be measurable
- Features should solve real problems
- Documentation should be updated with each change
- Test on fresh install before committing

---

## Contribution Guidelines

When implementing improvements:

1. **Measure First**: Benchmark before and after
2. **Document**: Update DEFINITIONS.md with changes
3. **Test**: Verify on clean system
4. **Commit**: Clear commit messages with measurements
5. **Share**: Update README with new features

---

## Resources

- [Zsh Performance Tips](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html)
- [Oh My Zsh Plugin Development](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization)
- [Powerlevel10k Performance](https://github.com/romkatv/powerlevel10k#how-fast-is-it)
- [Zsh Async](https://github.com/mafredri/zsh-async)
