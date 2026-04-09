# Custom Oh My Zsh Configuration

Portable, secure Zsh configuration for easy Mac setup with optimized performance, secret management, and Claude Code integration.

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

4. **Install dependencies**
   ```bash
   brew install jq
   ```

5. **Store your secrets securely**
   ```bash
   put-secret "github_token" "your_github_token"
   ```

6. **Reload shell**
   ```bash
   exec zsh
   ```

That's it. On reload, the plugins will automatically:
- Symlink `~/.vimrc` and install vim plugins (`vim-config`)
- Install the Claude API latency sampler via launchd (`claude-status`)
- Register the `claude_latency` Powerlevel10k segment
- Set up lazy-loaded version managers and completions

### Register Claude Code statusline (optional)

```bash
claude-status-register
```

> Fork this repo and use your own GitHub reference for personal customization

## What's Included

### Plugins

| Plugin | Description |
|--------|-------------|
| `envs` | Environment variables (FNM, Android SDK, etc.) |
| `paths` | PATH management for development tools |
| `apple-secret` | Secure secret management via macOS Keychain |
| `lazy-load` | Performance optimization (lazy-loads heavy plugins) |
| `aliases` | 60+ shortcuts for Laravel, Git, Modyo, etc. |
| `async-loader` | Async plugin loading |
| `lazy-version-managers` | Lazy-loaded fnm, rbenv, pyenv |
| `smart-npm` | Smart npm/pnpm/yarn detection |
| `docker-utils` | Docker shortcuts and utilities |
| `zsh-monitor` | Shell monitoring |
| `zsh-vi-mode` | Vi keybindings in the shell |
| `claude-status` | Claude API latency in p10k prompt + Claude Code statusline |
| `vim-config` | Centralized vim configuration with auto-setup |
| `reset-intelij` | JetBrains IDE trial reset utility |
| `zsh-autosuggestions` | Auto-completion (lazy-loaded) |
| `zsh-syntax-highlighting` | Syntax checking (lazy-loaded) |

### Theme
**Powerlevel10k** — Fast, customizable prompt with lean configuration

### Claude Code Integration (`claude-status`)
- Powerlevel10k segment auto-registered — shows API latency with color-coded levels
- Claude Code statusline — same indicator in the status bar (register with `claude-status-register`)
- macOS launchd job pings Anthropic's HTTP stack every 60s — no API key, no tokens
- Statistical thresholds adapt from 30-day rolling baseline (median + stdev)
- See `plugins/claude-status/README.md` for details

### Vim Configuration (`vim-config`)
- Auto-symlinks `~/.vimrc` and bootstraps vim-plug on first run
- Onedark theme, lightline statusline, FZF integration
- ALE linting, vim-surround, vim-commentary
- Cursor shape changes per mode (bar/block/underline)
- See `plugins/vim-config/vimrc` for full config

## File Structure

```
custom/
├── plugins/
│   ├── aliases/              # Shell aliases
│   ├── apple-secret/         # Keychain secret management
│   ├── async-loader/         # Async plugin loading
│   ├── claude-status/        # Claude API latency monitor
│   │   ├── latency-common.sh           # Shared cache reader
│   │   ├── latency-sampler.sh          # HTTP ping (run by launchd)
│   │   ├── statusline.sh               # Claude Code statusline
│   │   └── com.giorgiosaud.claude.latency.plist  # launchd template
│   ├── docker-utils/         # Docker shortcuts
│   ├── envs/                 # Environment variables
│   ├── lazy-load/            # Lazy-loading framework
│   ├── lazy-version-managers/ # fnm, rbenv, pyenv
│   ├── paths/                # PATH management
│   ├── smart-npm/            # npm/pnpm/yarn detection
│   ├── vim-config/           # Centralized vim config
│   │   ├── vimrc                       # The vim configuration
│   │   └── vim-config.plugin.zsh       # Auto-symlink setup
│   ├── zsh-autosuggestions/  # (lazy-loaded)
│   ├── zsh-syntax-highlighting/  # (lazy-loaded)
│   └── zsh-vi-mode/          # Vi keybindings
├── themes/                   # Powerlevel10k theme
├── p10k-custom.zsh          # p10k overrides (version-controlled)
├── zshrc                    # Main configuration
├── minimal-zshrc-template.txt  # Template for ~/.zshrc
├── DEFINITIONS.md           # Complete reference
├── SECURITY.md              # Security best practices
└── FUTURE_IMPROVEMENTS.md   # Optimization opportunities
```

## Security

Secrets are managed via macOS Keychain — never hardcoded:
```bash
put-secret "github_token" "your_token_here"   # store
get-secret "github_token"                       # retrieve
```

See `SECURITY.md` and `plugins/apple-secret/README.md` for details.

## Maintenance

### Update submodule plugins
```bash
cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
```

### Update vim plugins
```bash
vim +PlugUpdate +qa
```

### Test shell startup speed
```bash
time zsh -i -c exit
```

## Troubleshooting

- **Slow startup**: Verify lazy-loading is enabled, run `time zsh -i -c exit`
- **Claude latency not showing**: Run `p10k reload`, check `launchctl list com.giorgiosaud.claude.latency`
- **Vim plugins missing**: Run `vim +PlugInstall +qa`
- **Icons not rendering**: Use a Nerd Font (MesloLGS NF recommended)
- **Secret not working**: Run `get-secret "github_token"` to test keychain
- **Need details**: See `DEFINITIONS.md` for complete reference
