# Lazy Version Managers Plugin

Defers initialization of version managers (rbenv, pyenv, rvm) until first use.

## Purpose

Version manager initialization can be slow (100-200ms combined). This plugin defers initialization until you actually use the command, dramatically improving shell startup time.

## How It Works

Creates wrapper functions that:
1. Remove themselves
2. Initialize the actual version manager
3. Call the real command

```bash
rbenv() {
  unfunction rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}
```

## Supported Version Managers

- **rbenv** - Ruby version manager
- **pyenv** - Python version manager
- **rvm** - Ruby Version Manager

## Performance Impact

**Estimated savings**: 100-200ms faster startup
**Trade-off**: ~100ms delay on first use of `ruby`, `python`, etc.

## User Experience

First time you run `ruby` or `rbenv`:
- Small delay (~100ms) while initializing
- Subsequent commands are normal speed
- Completely transparent after first use

## When It Helps Most

- You don't use Ruby/Python immediately on every shell
- You have multiple version managers installed
- Shell startup time is important to you

## When to Skip

- You run Ruby/Python commands in your `.zshrc`
- You need version managers in your prompt
- You use these tools immediately every session

## Technical Details

Only creates wrappers if:
- Command is available (`command -v` check)
- Not already initialized

This prevents conflicts and works across different setups.

## Dependencies

- rbenv (optional)
- pyenv (optional)
- rvm (optional)

All are optional - plugin skips missing tools.
