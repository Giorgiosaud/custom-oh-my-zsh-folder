# Zsh Monitor Plugin

Performance profiling and monitoring tools for your shell configuration.

## Purpose

Provides utilities to benchmark, profile, and monitor your Zsh configuration's performance and resource usage.

## Commands

### zsh-benchmark [iterations]
Benchmark shell startup time:

```bash
$ zsh-benchmark      # 10 iterations (default)
$ zsh-benchmark 20   # 20 iterations

Benchmarking zsh startup (10 iterations)...
Run 1: 245ms
Run 2: 238ms
...
Average: 242ms
Min: 235ms
Max: 250ms
✓ Excellent startup time!
```

### zsh-profile [iterations]
Detailed startup profiling:

```bash
$ zsh-profile
Profiling zsh startup...
Profile saved to: /tmp/zsh-profile-12345.log

=== Slowest 20 operations ===
0.125 ~/.oh-my-zsh/oh-my-zsh.sh:42
0.089 plugins/zsh-syntax-highlighting
...
```

**Note**: Requires `ts` (moreutils) for timing analysis

### zsh-check
Quick performance check:

```bash
$ zsh-check
=== Quick Performance Check ===
Startup time: 245ms
Status: ✓ Excellent
Plugins: 14
Functions: 156
Memory: 12MB
```

### plugins-loaded
List all loaded plugins:

```bash
$ plugins-loaded
Loaded plugins (14):
  ✓ envs (custom)
  ✓ paths (custom)
  ✓ git (standard)
  ...
```

### plugins-benchmark
Benchmark individual plugin load times:

```bash
$ plugins-benchmark
Benchmarking plugin load times...
  envs:                     5ms
  paths:                   12ms
  git:                      8ms
  ...
Total plugin load time: 145ms
```

**Warning**: Re-sources plugins, may cause issues

### zsh-info
Comprehensive configuration info:

```bash
$ zsh-info
=== Zsh Configuration Info ===
Zsh Version: 5.9
Theme: powerlevel10k/powerlevel10k
Plugins: 14 loaded
Custom folder: ~/.oh-my-zsh/custom
Shell startup: Average: 242ms
Completion cache: Nov 17 10:30:15
```

### zsh-resources
Monitor shell resource usage:

```bash
$ zsh-resources
=== Shell Resource Usage ===
Process ID: 12345
Memory: 12MB
Functions: 156
Aliases: 45
Variables: 892
PATH entries: 24
FPATH entries: 12
```

## Performance Benchmarks

### Startup Time Ratings
- **<300ms**: Excellent ✓
- **300-500ms**: Good ✓
- **500-800ms**: Moderate ⚠️
- **>800ms**: Slow ⚠️ (needs optimization)

## Usage Examples

### Diagnose Slow Startup

```bash
# 1. Check overall time
$ zsh-check
Startup time: 850ms
Status: ⚠️  Could be improved

# 2. Profile to find culprit
$ zsh-profile

# 3. Check plugin times
$ plugins-benchmark
  ...
  some-heavy-plugin:      450ms  # ← Found it!
```

### Monitor After Changes

```bash
# Before optimization
$ zsh-benchmark 5
Average: 780ms

# Make changes...

# After optimization
$ zsh-benchmark 5
Average: 245ms  # 535ms improvement!
```

### Regular Health Check

```bash
$ zsh-check
# Quick overview of performance
```

## Dependencies

### Required
- None (all tools are built-in)

### Optional
- `ts` (moreutils) - For detailed timing in zsh-profile
  ```bash
  brew install moreutils
  ```
- `gdate` (coreutils) - For high-precision timing (used if available)
  ```bash
  brew install coreutils
  ```

## Tips

1. **Benchmark regularly** after config changes
2. **Profile when slow** to find bottlenecks
3. **Compare before/after** when optimizing
4. **Use zsh-check** for quick health check
5. **Monitor resources** if memory is a concern

## Troubleshooting

### "ts: command not found"
zsh-profile falls back to basic profiling without timing. Install moreutils for full features:
```bash
brew install moreutils
```

### "gdate: command not found"
Falls back to standard `date`. For better precision:
```bash
brew install coreutils
```

### Inaccurate Plugin Benchmarks
plugins-benchmark re-sources plugins which may give inaccurate results. Use zsh-profile instead for real-world timing.
