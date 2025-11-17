# Custom Oh My Zsh Configuration

Portable, secure Zsh configuration for easy Mac setup with optimized performance and secret management.

## Quick Setup (New Mac)

1. **Install Oh My Zsh**
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. **Clone this custom folder**
   ```bash
   cd ~/.oh-my-zsh
   rm -rf custom
   git clone --recurse-submodules git@github.com:Giorgiosaud/custom-oh-my-zsh-folder.git custom
   ```

3. **Use minimal .zshrc template**
   ```bash
   cat ~/.oh-my-zsh/custom/minimal-zshrc-template.txt > ~/.zshrc
   ```

4. **Store your secrets securely**
   ```bash
   put-secret "github_token" "your_github_token"
   ```

5. **Reload shell**
   ```bash
   source ~/.zshrc
   ```

> Fork this repo and use your own GitHub reference for personal customization

## Existing Installation Cleanup

If you're cleaning up an existing setup, see **`CLEANUP_INSTRUCTIONS.md`** for step-by-step guide to:
- Remove hardcoded secrets from main `.zshrc`
- Consolidate everything into custom folder
- Migrate to minimal `.zshrc` template

## What's Included

### Plugins (10 Total)
- **envs** - Environment variables (FNM, Android SDK, etc.)
- **paths** - PATH management for development tools
- **apple-secret** - 🔐 Secure secret management via macOS Keychain
- **lazy-load** - Performance optimization (lazy-loads heavy plugins)
- **git** - Git shortcuts and aliases
- **reset-intelij** - JetBrains IDE trial reset utility
- **vscode** - Visual Studio Code integration
- **node-modules-optimize** - Node.js utilities
- **zsh-vi-mode** - Vi keybindings
- **zsh-autosuggestions** + **zsh-syntax-highlighting** (lazy-loaded)

### Aliases
60+ shortcuts for:
- Laravel/PHP Artisan commands (`art`, `mmod`, `mmig`, etc.)
- Git workflows (`dev`, `prod`, `gacp()`, `gdump()`)
- Modyo CLI (`myc`, `mys`, `myp`)
- Custom functions for productivity

### Theme
**Powerlevel10k** - Fast, customizable prompt with lean configuration

### Version Managers
- fnm (Fast Node Manager)
- rbenv/rvm (Ruby)
- pyenv (Python)
- Bun (JavaScript runtime)

## Performance Optimizations

This configuration includes several optimizations:
1. **Lazy-loading** - Heavy plugins load after first prompt
2. **Consolidated FNM** - Single configuration point
3. **Removed unused tools** - nvm removed (not used)
4. **Fixed bugs** - PATH checks use correct conditionals

## Security 🔐

**✓ Secure Secret Management Implemented!**

This configuration uses the **apple-secret** plugin for secure credential storage:
```bash
# Secrets are retrieved from macOS Keychain, never hardcoded
export GITHUB_TOKEN=$(get-secret "github_token")
export NPM_TOKEN=$(get-secret "npm_token")
```

### Quick Start
```bash
# Store a secret
put-secret "github_token" "your_token_here"

# It's now safely encrypted in keychain!
```

- See `SECURITY.md` for complete guide
- See `plugins/apple-secret/README.md` for detailed usage
- **Never hardcode tokens** - always use keychain

## File Structure

```
custom/
├── plugins/              # Custom and third-party plugins
│   ├── envs/            # Environment variables
│   ├── paths/           # PATH management
│   ├── apple-secret/    # 🔐 Keychain secret management
│   ├── lazy-load/       # Performance optimization
│   ├── reset-intelij/   # JetBrains trial reset
│   ├── node-modules-optimize/  # Node.js utilities
│   ├── zsh-autosuggestions/    # Auto-completion (lazy-loaded)
│   ├── zsh-syntax-highlighting/  # Syntax checking (lazy-loaded)
│   └── zsh-vi-mode/     # Vi keybindings
├── themes/              # Powerlevel10k theme
├── aliases              # Shell aliases (60+ shortcuts)
├── zshrc               # Main configuration (sources everything)
├── minimal-zshrc-template.txt  # Template for main ~/.zshrc
├── README.md           # Overview and quick start
├── DEFINITIONS.md      # Complete reference and documentation
├── SECURITY.md         # Security best practices
└── FUTURE_IMPROVEMENTS.md  # Optimization opportunities
```

## Maintenance

### Update Plugins
```bash
cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
```

### Test Shell Startup Speed
```bash
time zsh -i -c exit
```

## Documentation

- **`README.md`** - This file (overview and setup)
- **`DEFINITIONS.md`** - Complete reference: structure, components, how everything works
- **`SECURITY.md`** - Security best practices and apple-secret guide
- **`FUTURE_IMPROVEMENTS.md`** - Optimization opportunities and enhancements
- **`minimal-zshrc-template.txt`** - Template for main ~/.zshrc
- **`plugins/apple-secret/README.md`** - Detailed secret management guide

## Troubleshooting

- **Slow startup**: Verify lazy-loading is enabled
- **Missing commands**: Check PATH with `echo $PATH`
- **Alias conflicts**: Run `alias` to see all aliases
- **Secret not working**: Run `get-secret "github_token"` to test keychain
- **Need details**: See `DEFINITIONS.md` for complete reference

## Resources

- [Oh My Zsh Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Zsh Documentation](http://zsh.sourceforge.net/)
