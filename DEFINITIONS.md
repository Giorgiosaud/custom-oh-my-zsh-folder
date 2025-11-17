# Zsh Configuration Definitions

Complete reference for the custom Oh My Zsh configuration structure, components, and functionality.

---

## Overview

This is a portable, secure, and optimized Zsh configuration that:
- Stores all customizations in one folder (`~/.oh-my-zsh/custom/`)
- Uses macOS Keychain for secure secret management
- Implements performance optimizations (lazy-loading, consolidated configs)
- Safe to commit to version control (no hardcoded secrets)
- Easy to deploy on new machines

---

## File Structure

```
~/.oh-my-zsh/custom/
├── plugins/              # Custom and third-party plugins
│   ├── envs/            # Environment variables and version managers
│   ├── paths/           # PATH management for development tools
│   ├── apple-secret/    # Keychain-based secret management
│   ├── lazy-load/       # Performance: deferred loading of heavy plugins
│   ├── aliases/         # (Optional) Modular aliases plugin
│   ├── reset-intelij/   # JetBrains trial reset utility
│   ├── node-modules-optimize/  # Node.js utilities
│   ├── zsh-autosuggestions/    # Auto-completion from history
│   ├── zsh-syntax-highlighting/  # Real-time syntax checking
│   └── zsh-vi-mode/     # Vi keybindings for Zsh
├── themes/
│   └── powerlevel10k/   # Fast, customizable prompt theme
├── aliases              # Shell aliases and functions (60+)
├── zshrc               # Main configuration file
├── minimal-zshrc-template.txt  # Template for ~/.zshrc
├── README.md           # Setup and usage guide
├── SECURITY.md         # Security best practices
├── DEFINITIONS.md      # This file
└── FUTURE_IMPROVEMENTS.md  # Optimization opportunities
```

---

## Core Components

### 1. Main Configuration (zshrc)

**Location**: `~/.oh-my-zsh/custom/zshrc`

**Purpose**: Central configuration file that loads everything

**Contents**:
- Amazon Q integration (optional)
- Powerlevel10k theme setup
- Plugin list (11 plugins)
- Oh My Zsh initialization
- FZF fuzzy finder integration
- rbenv initialization
- VSCode-specific configuration
- Secure secret management

**Key Configuration**:
```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
export SONAR_HOME=/usr/local/Cellar/sonar-scanner/{version}/libexec
export SONAR=$SONAR_HOME/bin
export PATH=$SONAR:$PATH

plugins=(
    envs
    paths
    git
    reset-intelij
    vscode
    node-modules-optimize
    zsh-vi-mode
    lazy-load
    apple-secret
    aliases
)
```

---

## Plugins

### Custom Plugins

#### 1. envs
**Location**: `plugins/envs/envs.plugin.zsh`
**Purpose**: Centralized environment variable management

**Exports**:
- `FNM_PATH` - Fast Node Manager path
- `GPG_TTY` - GPG terminal for signing
- `LC_ALL` - Locale settings
- `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_AVD_HOME` - Android development
- `BUN_INSTALL` - Bun JavaScript runtime

**Features**:
- Single source of truth for environment variables
- FNM initialization integrated
- Disables zsh compfix warnings

#### 2. paths
**Location**: `plugins/paths/paths.plugin.zsh`
**Purpose**: Manages PATH for all development tools

**Categories**:
- **Local binaries**: `~/.local/bin`, composer
- **Project-specific**: `./node_modules/.bin`, `./vendor/bin`
- **Development tools**: Sonar, VSCode remote containers
- **Version managers**: pyenv, rvm, bun
- **Specialized tools**: Elasticsearch, OpenSSL
- **Ruby**: RVM initialization
- **Node**: FNM integration

**Features**:
- Organized by logical groups
- Sources custom aliases file
- Directory existence checks before PATH additions
- Duplicates removed

#### 3. apple-secret
**Location**: `plugins/apple-secret/apple-secret.plugin.zsh`
**Purpose**: Secure secret management via macOS Keychain

**Functions**:
- `get-secret <name>` - Retrieve secret from keychain
- `put-secret <name> <value>` - Store/update secret in keychain
- `delete-secret <name>` - Remove secret from keychain
- `list-secrets` - Show all stored secrets
- `has-secret <name>` - Check if secret exists (exit code)

**Security**:
- AES-256 encryption at rest
- Protected by user password/Touch ID
- No secrets in plain text files
- Safe to commit configuration

**Usage Example**:
```bash
# Store
put-secret "github_token" "ghp_your_token"

# Retrieve
export GITHUB_TOKEN=$(get-secret "github_token")

# Check
if has-secret "github_token"; then
  echo "Token configured"
fi
```

#### 4. lazy-load
**Location**: `plugins/lazy-load/lazy-load.plugin.zsh`
**Purpose**: Improve shell startup time by deferring heavy plugin loading

**Mechanism**:
- Uses `add-zsh-hook precmd` to load plugins after first prompt
- Removes hooks after loading (one-time execution)

**Deferred Plugins**:
- `zsh-syntax-highlighting` - Heavy regex processing
- `zsh-autosuggestions` - History scanning

**Performance Impact**:
- ~100-300ms faster shell startup
- Plugins still load before user interaction
- Transparent to user experience

#### 5. aliases (Plugin)
**Location**: `plugins/aliases/` (if implemented as plugin)
**Purpose**: Modular alias management

**Note**: Currently aliases are in standalone file `custom/aliases`. Can be converted to plugin format for better organization.

#### 6. reset-intelij
**Location**: `plugins/reset-intelij/`
**Purpose**: Reset JetBrains IDE trial periods

**Functionality**:
- Kills running JetBrains processes
- Removes evaluation keys
- Clears trial data from preferences

**Warning**: Educational purposes only

#### 7. node-modules-optimize
**Location**: `plugins/node-modules-optimize/`
**Purpose**: Node.js project utilities

**Functions**:
- `checkmodules()` - Display size of node_modules
- `removenodemodules()` - Recursively delete node_modules folders

### Third-Party Plugins

#### 8. git (Oh My Zsh standard)
**Purpose**: Git shortcuts and aliases

#### 9. vscode (Oh My Zsh standard)
**Purpose**: Visual Studio Code integration

#### 10. zsh-vi-mode
**Source**: https://github.com/jeffreytse/zsh-vi-mode
**Purpose**: Vi keybindings in Zsh

#### 11. zsh-autosuggestions (lazy-loaded)
**Source**: https://github.com/zsh-users/zsh-autosuggestions
**Purpose**: Fish-like autosuggestions based on history

#### 12. zsh-syntax-highlighting (lazy-loaded)
**Source**: https://github.com/zsh-users/zsh-syntax-highlighting
**Purpose**: Real-time syntax checking of commands

---

## Aliases File

**Location**: `custom/aliases`
**Format**: Plain text, sourced by paths plugin
**Count**: 60+ aliases and functions

**Categories**:

### Laravel/PHP
```bash
art='php artisan'
mmod='php artisan make:model'
mmig='php artisan make:migration'
mseeder='php artisan make:seeder'
mig='php artisan migrate'
migr='php artisan migrate:refresh'
```

### Git Workflows
```bash
dev='git checkout develop'
prod='git checkout master'
pull='git pull'
devpull='git checkout develop && git pull'
gl="git log --graph --pretty=format:'...'"
gdump="git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D"
```

### Functions
```bash
gacp() {
  gaa
  gc -m "$1"
  gp
}

runCommand() {
  for d in ./*/ ; do /bin/zsh -c "(cd "$d" && "$@")"; done
}
```

### Modyo CLI
```bash
myc='modyo-cli create'
mys='modyo-cli start'
myp='modyo-cli push'
```

### System
```bash
hosts="sudo vim /etc/hosts"
vhosts="vi /Applications/XAMPP/etc/extra/httpd-vhosts.conf"
reload="source ~/.zshrc"
```

---

## Theme: Powerlevel10k

**Location**: `themes/powerlevel10k/`
**Configuration**: `~/.p10k.zsh`

**Features**:
- Lean prompt style (2 lines)
- Nerdfont v3 + Powerline icons
- Instant prompt for fast startup
- Transient prompt enabled

**Left Prompt**:
- OS icon
- Directory
- Git status
- Prompt character

**Right Prompt** (active segments):
- Exit code
- Command execution time
- Background jobs
- Version managers: rbenv, rvm, pyenv, goenv
- Cloud tools (if applicable)

**Configuration**:
- Run `p10k configure` to customize
- Configuration saved to `~/.p10k.zsh`
- VSCode-specific: Instant prompt disabled

---

## Version Managers

### Configured and Active

1. **fnm (Fast Node Manager)**
   - Location: `/opt/homebrew/opt/fnm/bin`
   - Initialized in: `envs` plugin
   - Auto-switches Node version based on `.node-version` or `.nvmrc`

2. **rbenv (Ruby)**
   - Initialized in: `custom/zshrc`
   - Command: `rbenv init -`

3. **rvm (Ruby Version Manager)**
   - PATH: `~/.rvm/bin`
   - Initialized in: `paths` plugin
   - Script: `~/.rvm/scripts/rvm`

4. **pyenv (Python)**
   - Shims: `~/.pyenv/shims`
   - Added to PATH in: `paths` plugin

5. **bun (JavaScript runtime)**
   - Install path: `~/.bun`
   - Initialized in: `paths` plugin
   - Completions: `~/.bun/_bun`

### Removed (Not Used)

- **nvm** - Configuration removed for performance
  - Use fnm instead (faster, compatible)

---

## Secret Management

### Implementation

**Plugin**: `apple-secret`
**Backend**: macOS Keychain
**Encryption**: AES-256

### Current Secrets

```bash
# In custom/zshrc
export GITHUB_TOKEN=$(get-secret "github_token")
export GITHUB_USERNAME=giorgiosaud
```

### Workflow

1. **Store secret**:
   ```bash
   put-secret "github_token" "ghp_your_token_here"
   ```

2. **Access in config**:
   ```bash
   export GITHUB_TOKEN=$(get-secret "github_token")
   ```

3. **Verify**:
   ```bash
   get-secret "github_token"  # Shows value
   echo $GITHUB_TOKEN          # Shows value
   ```

### Security Features

- ✅ Encrypted at rest (AES-256)
- ✅ Protected by system password/Touch ID
- ✅ Never in plain text files
- ✅ Safe to commit entire custom folder
- ✅ Survives system restarts
- ✅ Works across terminal sessions

---

## Integration Points

### 1. FZF (Fuzzy Finder)
**Integration**: `[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh`
**Purpose**: Command-line fuzzy finder
**Shortcuts**: Ctrl+R (history), Ctrl+T (files), Alt+C (directories)

### 2. Amazon Q
**Integration**: Optional pre-block in custom/zshrc
**Purpose**: AI coding assistant integration
**Location**: `~/Library/Application Support/amazon-q/shell/zshrc.pre.zsh`

### 3. Pure Prompt (Legacy)
**Path Addition**: `fpath+=$HOME/.oh-my-zsh/custom/pure`
**Status**: Not actively used (using Powerlevel10k instead)

---

## Performance Characteristics

### Startup Time
- **Target**: <400ms
- **Optimization**: Lazy-loading of heavy plugins
- **Measurement**: `time zsh -i -c exit`

### Memory Usage
- Minimal: Only loads what's needed
- Lazy-loaded plugins reduce initial footprint

### Load Order
1. Amazon Q pre-block (if present)
2. Theme setup (Powerlevel10k)
3. Environment variables (envs plugin)
4. PATH setup (paths plugin)
5. Core plugins (git, vscode, etc.)
6. Oh My Zsh initialization
7. FZF integration
8. P10k configuration
9. rbenv initialization
10. VSCode config (conditional)
11. Secret exports (apple-secret)
12. Lazy-loaded plugins (on first prompt)

---

## Main ~/.zshrc Template

**Location**: `custom/minimal-zshrc-template.txt`
**Size**: 17 lines
**Purpose**: Minimal main .zshrc that sources custom config

**Content**:
```bash
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Load custom configuration
source ~/.oh-my-zsh/custom/zshrc

# P10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

---

## Development Tools Support

### Configured
- Node.js (via fnm)
- Ruby (via rbenv/rvm)
- Python (via pyenv)
- PHP (composer in PATH)
- Bun (JavaScript runtime)
- Docker (vscode-remote-containers)
- Android SDK
- SonarQube scanner

### Version Manager Priority
1. fnm (Node.js) - Primary, fast
2. rbenv (Ruby) - Primary
3. rvm (Ruby) - Fallback
4. pyenv (Python) - Standard

---

## Key Differences from Default Oh My Zsh

| Feature | Default OMZ | This Config |
|---------|-------------|-------------|
| Configuration | Scattered in ~/.zshrc | All in custom/ |
| Secrets | Often hardcoded | Keychain via apple-secret |
| Plugins | ~10-20 standard | 11 optimized + lazy-loaded |
| Startup Time | 500-800ms | 200-400ms |
| Theme | robbyrussell | Powerlevel10k |
| Portability | Manual setup | Clone and go |
| Version Control | Risky (secrets) | Safe (no secrets) |
| PATH Management | Ad-hoc | Organized in paths plugin |
| Aliases | In main .zshrc | Separate file |

---

## Plugin Loading Order

```
envs         → Sets environment variables first
paths        → Uses env vars, configures PATH
git          → Git shortcuts
reset-intelij → Utility
vscode       → IDE integration
node-modules-optimize → Node utilities
zsh-vi-mode  → Vi keybindings
lazy-load    → Sets up deferred loading
apple-secret → Secret management functions
aliases      → (Optional plugin format)

(After first prompt, lazy-load triggers:)
zsh-autosuggestions  → History-based suggestions
zsh-syntax-highlighting → Syntax checking
```

---

## Configuration Philosophy

### Principles

1. **Portability**: Everything in one folder
2. **Security**: Secrets in keychain, never in files
3. **Performance**: Lazy-load what's heavy
4. **Maintainability**: Organized, documented, modular
5. **Simplicity**: Minimal main .zshrc, all complexity in custom/

### Design Decisions

- **Why lazy-load?** Heavy plugins (syntax highlighting, autosuggestions) add 200-300ms startup time
- **Why keychain?** Native, secure, no external tools needed
- **Why separate plugins?** Easier to enable/disable, maintain, understand
- **Why consolidate FNM?** Was duplicated 3x, now single source in envs
- **Why remove nvm?** Not used, fnm is faster and compatible

---

## Verification Commands

```bash
# Check configuration loaded
echo $ZSH_THEME           # powerlevel10k/powerlevel10k
echo $plugins             # List of 11 plugins

# Test secrets
get-secret "github_token" # Should return token
echo $GITHUB_TOKEN        # Should be set

# Verify paths
which fnm                 # Should find fnm
which rbenv              # Should find rbenv
echo $PATH | tr ':' '\n' # Should show organized paths

# Test aliases
type gacp                 # Should show function
alias | grep art          # Should show Laravel aliases

# Performance
time zsh -i -c exit       # Should be < 500ms
```

---

## Summary

This configuration is:
- ✅ **Secure**: Keychain-based secret management
- ✅ **Fast**: Lazy-loading optimization
- ✅ **Portable**: Self-contained in custom folder
- ✅ **Safe**: No secrets in files, safe to commit
- ✅ **Organized**: Modular plugin structure
- ✅ **Documented**: Comprehensive guides
- ✅ **Tested**: Battle-tested optimizations
