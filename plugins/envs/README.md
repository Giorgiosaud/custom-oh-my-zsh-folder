# Envs Plugin

Environment variables and version manager configuration.

## Purpose

Centralizes all environment variable exports in one location for better organization and maintainability.

## Exports

### Development Tools
- `FNM_PATH` - Fast Node Manager binary path
- `ANDROID_HOME` - Android SDK home directory
- `ANDROID_SDK_ROOT` - Android SDK root
- `ANDROID_AVD_HOME` - Android Virtual Device home
- `BUN_INSTALL` - Bun JavaScript runtime installation path

### System Configuration
- `GPG_TTY` - GPG terminal for signing
- `LC_ALL` - Locale settings (en_US.UTF-8)
- `ZSH_DISABLE_COMPFIX` - Disable insecure directory warnings

### Version Managers
- Initializes FNM (Fast Node Manager) with auto-switching on cd

## Usage

This plugin is loaded automatically. All environment variables are available in your shell session.

## Adding New Environment Variables

Edit `envs.plugin.zsh` and add:

```bash
export YOUR_VAR="value"
```

**Security Note**: Never hardcode secrets here. Use the `apple-secret` plugin instead.

## Dependencies

- FNM (optional) - Fast Node Manager
- Android SDK (optional) - For Android development
- Bun (optional) - JavaScript runtime
