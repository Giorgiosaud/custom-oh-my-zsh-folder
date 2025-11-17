# Async-Loader Plugin

Loads non-critical plugins in background for faster shell startup.

## Purpose

Asynchronously loads nice-to-have plugins that aren't needed immediately, allowing the shell to become interactive faster.

## How It Works

Uses zsh background jobs (`&!`) to load plugins in parallel with shell initialization:

```bash
{
  source plugin1...
  source plugin2...
} &!  # Run in background, detached
```

## Async-Loaded Plugins

- **FZF integration** - Fuzzy finder (~30-50ms)
- **node-modules-optimize** - Rarely used utilities (~10-20ms)

## Performance Impact

**Estimated savings**: 40-70ms faster startup
**Trade-off**: Small delay before async plugins available (~100-200ms)

## When to Use

Load plugins asynchronously when:
- They're not used immediately on shell start
- They're convenience features, not critical
- They don't export essential functions/aliases
- They're relatively heavy to load

## When NOT to Use

Don't load asynchronously if:
- Plugin exports functions used in prompt
- Plugin required for basic shell operation
- Plugin modifies shell behavior immediately
- Plugin is already fast (<10ms)

## Adding More Plugins

Edit `async-loader.plugin.zsh`:

```bash
{
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  [ -f $ZSH_CUSTOM/plugins/your-plugin/your-plugin.plugin.zsh ] && \
    source $ZSH_CUSTOM/plugins/your-plugin/your-plugin.plugin.zsh
} &!
```

## Dependencies

- None (conditional loading of optional features)
