# Lazy-Load Plugin

Defers loading of heavy plugins until after first prompt display.

## Purpose

Improves shell startup time by delaying the loading of resource-intensive plugins (zsh-syntax-highlighting and zsh-autosuggestions) until after the prompt appears.

## How It Works

Uses `add-zsh-hook precmd` to load plugins on first prompt display:

1. Shell starts
2. Prompt appears instantly
3. Before first command, hook triggers
4. Heavy plugins load in background
5. Hook self-removes after loading

## Deferred Plugins

- **zsh-syntax-highlighting** - Real-time syntax checking (~100-150ms)
- **zsh-autosuggestions** - History-based suggestions (~50-100ms)

## Performance Impact

**Estimated savings**: 150-250ms faster startup
**Trade-off**: Plugins available after ~100ms delay (imperceptible to user)

## User Experience

Completely transparent. Plugins are loaded before you can type your first command, so there's no noticeable difference except faster shell startup.

## Technical Details

```bash
function _lazy_load_syntax_highlighting() {
  source plugin...
  add-zsh-hook -d precmd _lazy_load_syntax_highlighting  # Remove self
}
add-zsh-hook precmd _lazy_load_syntax_highlighting
```

## Dependencies

- zsh-syntax-highlighting (will gracefully skip if not installed)
- zsh-autosuggestions (will gracefully skip if not installed)
