# Paths Plugin

Centralized PATH management for all development tools and binaries.

## Purpose

Manages PATH additions for development tools, version managers, and utilities. Uses directory caching for improved performance.

## Features

- **Performance**: Caches directory checks to avoid repeated filesystem access
- **Organization**: Paths grouped by category
- **Conditional**: Only adds paths that exist
- **Aliases Integration**: Sources custom aliases file

## PATH Categories

### Local Binaries
- `~/.local/bin`

### Project-Specific
- `./node_modules/.bin` - npm binaries
- `./vendor/bin` - Composer binaries

### Development Tools
- `~/Project/sonar-bin/bin` - SonarQube scanner
- `/usr/local/sbin` - System binaries

### Version Managers
- `~/.pyenv/shims` - Python
- `~/.rvm/bin` - Ruby
- `~/.bun/bin` - Bun
- `~/.console-ninja/.bin` - Console Ninja
- `~/.amplify/bin` - AWS Amplify

### Specialized Tools
- `/usr/local/opt/elasticsearch@2.4/bin` - Elasticsearch
- `/usr/local/opt/openssl@1.1/bin` - OpenSSL
- `$BUN_INSTALL/bin` - Bun runtime
- `$FNM_PATH` - Fast Node Manager

## Performance

Uses `_has_dir()` caching function to reduce filesystem checks:

```bash
typeset -gA _dir_cache
_has_dir() {
  # Caches directory existence checks
}
```

**Benefit**: ~20-50ms faster startup compared to repeated `-d` checks.

## Adding New Paths

Edit `paths.plugin.zsh`:

```bash
_has_dir /your/path && export PATH=$PATH:/your/path
```

## Dependencies

- None (all checks are conditional)
