# Docker Utils Plugin

Shortcuts and utilities for Docker and Docker Compose workflows.

## Purpose

Provides convenient aliases and functions for common Docker operations, making container management faster and easier.

## Features

- Short aliases for common commands
- Smart docker-compose detection
- Cleanup utilities
- Container inspection helpers

## Aliases

### Docker Compose
```bash
dc              # docker-compose
dcu             # docker-compose up -d
dcd             # docker-compose down
dcr             # docker-compose restart
dcl             # docker-compose logs -f
dcp             # docker-compose ps
```

### Docker
```bash
d               # docker
dps             # docker ps
dpsa            # docker ps -a
di              # docker images
dex             # docker exec -it
dl              # docker logs -f
```

## Functions

### dcu-smart
Smart docker-compose up that checks for compose file first:

```bash
$ dcu-smart
# Checks for docker-compose.yml/yaml, then runs: docker-compose up -d
```

### docker-cleanup
Complete Docker cleanup (containers, images, volumes, networks):

```bash
$ docker-cleanup
Cleaning up Docker resources...
→ Removing stopped containers...
→ Removing unused images...
→ Removing unused volumes...
→ Removing unused networks...
✓ Docker cleanup complete
```

### dstats [container]
Show container resource stats:

```bash
$ dstats                # All containers
$ dstats myapp          # Specific container
```

### dsh <container> [shell]
Quick shell access to container:

```bash
$ dsh myapp             # Opens sh in myapp
$ dsh myapp bash        # Opens bash in myapp
```

### docker-ips
List all container IPs:

```bash
$ docker-ips
/myapp - 172.17.0.2
/database - 172.17.0.3
```

### dcl-service <service>
Tail logs for specific compose service:

```bash
$ dcl-service api
# Follows logs for 'api' service
```

## Usage Examples

```bash
# Start project
dcu               # docker-compose up -d

# Check status
dcp               # docker-compose ps

# View logs
dcl               # All services
dcl-service api   # Just API service

# Access container
dsh myapp bash    # Get bash shell in myapp

# Cleanup when done
docker-cleanup    # Remove all unused Docker resources
```

## Requirements

- Docker (plugin checks if installed)
- Docker Compose (optional, for dc* commands)

If Docker isn't installed, the plugin gracefully skips loading.

## Performance

All aliases and functions are lightweight (<1ms overhead).

## Safety

- `docker-cleanup` uses `-f` (force) - be careful in production
- Always backup data before cleanup
- Review what will be removed first: `docker system df`
