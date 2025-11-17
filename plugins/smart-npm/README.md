# Smart NPM Plugin

Auto-detects and uses the correct package manager based on project lockfile.

## Purpose

Automatically switches between npm, yarn, pnpm, and bun based on which lockfile is present, so you can use `npm` for everything.

## Features

- **Auto-detection** - Checks lockfile and uses correct package manager
- **Universal commands** - Use `npm` regardless of actual manager
- **Project info** - Quick project details and script listing
- **Smart aliases** - Work with any package manager

## How It Works

When you run `npm install`, it:
1. Checks for lockfiles in this order:
   - `bun.lockb` → uses `bun`
   - `pnpm-lock.yaml` → uses `pnpm`
   - `yarn.lock` → uses `yarn`
   - `package-lock.json` → uses `npm`
2. Runs the appropriate package manager
3. Shows which one it's using

## Commands

### Wrapped npm Command
```bash
npm install     # Auto-detects: bun install / pnpm install / yarn / npm install
npm run dev     # Uses detected package manager
npm test        # Uses detected package manager
```

### Aliases
```bash
ni              # npm install
nr              # npm run
nrd             # npm run dev
nrb             # npm run build
nrt             # npm run test
ns              # npm start
```

### Utility Functions
```bash
which-pm        # Show detected package manager and version
project-info    # Show project details, scripts, and tools
```

## Examples

```bash
# In a pnpm project
$ npm install lodash
→ Using pnpm (detected from lockfile)
$ pnpm add lodash

# Check what's being used
$ which-pm
Package manager: pnpm
Version: 8.10.0

# Get project info
$ project-info
Project: my-app
Version: 1.0.0
Node: v20.10.0
Package Manager: pnpm
Scripts: dev, build, test, lint
```

## Benefits

- **One command** - Use `npm` everywhere
- **No mistakes** - Can't accidentally mix package managers
- **Fast workflow** - No need to remember which project uses what
- **Team consistency** - Everyone uses the same manager per project

## Edge Cases

- If no lockfile exists, defaults to `npm`
- Original `npm` command still available as `command npm`
- Works in monorepos (checks current directory)

## Disabling

To bypass detection and use actual npm:

```bash
command npm install  # Forces npm regardless of lockfile
```

## Dependencies

- npm (usually pre-installed with Node.js)
- yarn, pnpm, or bun (optional, only if you use them)
