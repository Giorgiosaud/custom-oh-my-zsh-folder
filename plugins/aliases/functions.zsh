# Custom Functions

# Run command in all subdirectories
# Usage: runCommand <command>
# Example: runCommand git pull
runCommand() {
  for d in ./*/ ; do
    /bin/zsh -c "(cd "$d" && "$@")"
  done
}
