# Aliases Plugin

Modular alias management organized by topic.

## Purpose

Provides commonly-used shortcuts and functions organized into topic-based files for better maintainability.

## Structure

```
aliases/
├── aliases.plugin.zsh  # Main loader
├── git.zsh             # Git aliases and functions
├── system.zsh          # System utilities
└── functions.zsh       # Custom functions
```

## Included Aliases

### Git (git.zsh)
- `dev` - Switch to develop branch
- `prod` - Switch to master branch
- `pull` - Git pull
- `devpull` - Checkout develop and pull
- `prodpull` - Checkout master and pull
- `gl` - Pretty git log with graph
- `gdump` - Clean up deleted remote branches

### System (system.zsh)
- `reload` - Reload zsh configuration

### Functions (functions.zsh)
- `gacp(message)` - Git add, commit, and push in one command
- `runCommand(cmd)` - Execute command in all subdirectories

## Usage Examples

```bash
# Git workflow
dev                    # Switch to develop branch
gacp "Add new feature" # Add, commit, push with message
gdump                  # Clean up old branches

# Utilities
runCommand git pull    # Pull in all subdirectories
reload                 # Reload shell
```

## Adding New Aliases

1. Choose appropriate topic file (or create new one)
2. Add alias or function
3. Update `aliases.plugin.zsh` if creating new file:

```bash
source ${0:A:h}/your-new-topic.zsh
```

## Disabling Topics

Comment out the source line in `aliases.plugin.zsh`:

```bash
# source ${0:A:h}/modyo.zsh  # Disabled
```
