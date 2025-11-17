# Docker Utilities
# Shortcuts and helpers for Docker and Docker Compose workflows

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  return 0  # Skip if Docker not installed
fi

# Docker Compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'
alias dcl='docker-compose logs -f'
alias dcp='docker-compose ps'

# Docker shortcuts
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs -f'

# Smart docker compose up
dcu-smart() {
  if [[ -f docker-compose.yml ]] || [[ -f docker-compose.yaml ]]; then
    docker-compose up -d "$@"
  else
    echo "✗ No docker-compose.yml found in current directory"
    return 1
  fi
}

# Docker cleanup
docker-cleanup() {
  echo "Cleaning up Docker resources..."
  echo ""
  echo "→ Removing stopped containers..."
  docker container prune -f
  echo "→ Removing unused images..."
  docker image prune -af
  echo "→ Removing unused volumes..."
  docker volume prune -f
  echo "→ Removing unused networks..."
  docker network prune -f
  echo ""
  echo "✓ Docker cleanup complete"
}

# Docker stats for specific service
dstats() {
  if [ -z "$1" ]; then
    docker stats --no-stream
  else
    docker stats --no-stream "$1"
  fi
}

# Quick container shell access
dsh() {
  local container="$1"
  local shell="${2:-sh}"

  if [ -z "$container" ]; then
    echo "Usage: dsh <container> [shell]"
    echo "Example: dsh myapp bash"
    return 1
  fi

  docker exec -it "$container" "$shell"
}

# List all container IPs
docker-ips() {
  docker ps -q | xargs -I {} docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {}
}

# Docker Compose logs for specific service
dcl-service() {
  if [ -z "$1" ]; then
    echo "Usage: dcl-service <service_name>"
    return 1
  fi
  docker-compose logs -f "$1"
}
