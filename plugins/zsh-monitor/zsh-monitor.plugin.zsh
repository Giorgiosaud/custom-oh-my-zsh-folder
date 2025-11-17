# Zsh Monitoring and Profiling Tools
# Tools for debugging and optimizing shell performance

# Profile zsh startup
zsh-profile() {
  local profile_file="/tmp/zsh-profile-$$.log"
  local iterations="${1:-1}"

  if [ "$iterations" -gt 1 ]; then
    echo "Running $iterations startup benchmarks..."
    zsh-benchmark "$iterations"
    return
  fi

  echo "Profiling zsh startup..."
  PS4=$'%D{%M%S%.} %N:%i> ' zsh -x -i -c exit 2>&1 | \
    ts -i "%.s" > "$profile_file" 2>/dev/null || \
    PS4=$'%D{%M%S%.} %N:%i> ' zsh -x -i -c exit > "$profile_file" 2>&1

  echo "Profile saved to: $profile_file"
  echo ""
  echo "=== Slowest 20 operations ==="
  if command -v ts &> /dev/null; then
    cat "$profile_file" | sort -k1 -n | tail -20
  else
    echo "⚠️  Install 'ts' (moreutils) for timing analysis"
    tail -20 "$profile_file"
  fi
}

# Benchmark zsh startup time
zsh-benchmark() {
  local iterations="${1:-10}"
  local total=0
  local times=()

  echo "Benchmarking zsh startup ($iterations iterations)..."
  echo ""

  for i in {1..$iterations}; do
    local start=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
    zsh -i -c exit 2>/dev/null
    local end=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
    local time=$((end - start))

    times+=($time)
    total=$((total + time))
    echo "Run $i: ${time}ms"
  done

  echo ""
  local avg=$((total / iterations))
  echo "Average: ${avg}ms"

  # Calculate min/max
  local min=${times[1]}
  local max=${times[1]}
  for t in $times; do
    [ $t -lt $min ] && min=$t
    [ $t -gt $max ] && max=$t
  done

  echo "Min: ${min}ms"
  echo "Max: ${max}ms"
  echo ""

  if [ $avg -lt 300 ]; then
    echo "✓ Excellent startup time!"
  elif [ $avg -lt 500 ]; then
    echo "✓ Good startup time"
  elif [ $avg -lt 800 ]; then
    echo "⚠️  Moderate startup time, consider optimizations"
  else
    echo "⚠️  Slow startup time, optimization recommended"
  fi
}

# Show loaded plugins
plugins-loaded() {
  echo "Loaded plugins ($#plugins):"
  for plugin in $plugins; do
    if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
      echo "  ✓ $plugin (custom)"
    else
      echo "  ✓ $plugin (standard)"
    fi
  done
}

# Benchmark individual plugins
plugins-benchmark() {
  echo "Benchmarking plugin load times..."
  echo "(Note: This reloads plugins, may cause issues)"
  echo ""

  local total=0

  for plugin in $plugins; do
    local plugin_file=""

    if [[ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]]; then
      plugin_file="$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
    elif [[ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
      plugin_file="$ZSH/plugins/$plugin/$plugin.plugin.zsh"
    else
      echo "  $plugin: skipped (file not found)"
      continue
    fi

    local start=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
    source "$plugin_file" 2>/dev/null
    local end=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
    local time=$((end - start))

    total=$((total + time))
    printf "  %-25s %4dms\n" "$plugin:" "$time"
  done

  echo ""
  echo "Total plugin load time: ${total}ms"
}

# Show zsh configuration info
zsh-info() {
  echo "=== Zsh Configuration Info ==="
  echo ""
  echo "Zsh Version: $ZSH_VERSION"
  echo "Oh My Zsh: ${ZSH_VERSION:-not detected}"
  echo "Theme: $ZSH_THEME"
  echo "Plugins: $#plugins loaded"
  echo "Custom folder: $ZSH_CUSTOM"
  echo ""
  echo "Shell startup: $(zsh-benchmark 3 2>&1 | grep Average)"
  echo ""
  echo "=== Performance ==="
  local compinit_check=$(ls -l ~/.zcompdump 2>/dev/null | awk '{print $6" "$7" "$8}')
  if [ -n "$compinit_check" ]; then
    echo "Completion cache: $compinit_check"
  else
    echo "Completion cache: not found"
  fi
}

# Monitor shell resource usage
zsh-resources() {
  echo "=== Shell Resource Usage ==="
  echo ""
  echo "Process ID: $$"
  echo "Memory: $(ps -o rss= -p $$ | awk '{print int($1/1024)"MB"}')"
  echo "Functions: $(print -l ${(ok)functions} | wc -l | tr -d ' ')"
  echo "Aliases: $(alias | wc -l | tr -d ' ')"
  echo "Variables: $(print -l ${(k)parameters} | wc -l | tr -d ' ')"
  echo ""
  echo "PATH entries: $(echo $PATH | tr ':' '\n' | wc -l | tr -d ' ')"
  echo "FPATH entries: $(echo $FPATH | tr ':' '\n' | wc -l | tr -d ' ')"
}

# Quick performance check
zsh-check() {
  echo "=== Quick Performance Check ==="
  echo ""

  # Startup time
  local start=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
  zsh -i -c exit 2>/dev/null
  local end=$(($(gdate +%s%N 2>/dev/null || date +%s000000000)/1000000))
  local startup_time=$((end - start))

  echo "Startup time: ${startup_time}ms"

  if [ $startup_time -lt 300 ]; then
    echo "Status: ✓ Excellent"
  elif [ $startup_time -lt 500 ]; then
    echo "Status: ✓ Good"
  else
    echo "Status: ⚠️  Could be improved"
  fi

  echo ""
  echo "Plugins: $#plugins"
  echo "Functions: $(print -l ${(ok)functions} | wc -l | tr -d ' ')"
  echo "Memory: $(ps -o rss= -p $$ | awk '{print int($1/1024)"MB"}')"
}
