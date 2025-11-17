# Apple Secret Plugin

Secure secret management for Zsh using macOS Keychain.

## Overview

This plugin provides a simple, secure way to store and retrieve secrets (API tokens, passwords, keys) using the native macOS Keychain. Secrets are encrypted and never stored in plain text in your configuration files.

## Why Use This?

**Problem**: Hardcoding secrets in shell config files is insecure:
- Visible in plain text
- Accidentally committed to git
- Exposed to any process on your system
- Difficult to rotate

**Solution**: Store secrets in macOS Keychain and retrieve them dynamically:
- AES-256 encryption
- Protected by user password/Touch ID
- Safe to commit your zsh config
- Easy secret rotation

## Installation

This plugin is included in the custom Oh My Zsh configuration. Ensure it's in your plugins list:

```bash
# In ~/.oh-my-zsh/custom/zshrc
plugins=(
  ...
  apple-secret
  ...
)
```

## Usage

### Basic Commands

#### Store a Secret
```bash
put-secret "secret_name" "secret_value"
```

**Example**:
```bash
put-secret "github_token" "ghp_abc123xyz"
put-secret "npm_token" "npm_xyz789"
put-secret "api_key" "sk-proj-abc123"
```

**Output**: `✓ Secret 'github_token' stored successfully in keychain`

#### Retrieve a Secret
```bash
get-secret "secret_name"
```

**Example**:
```bash
# Direct retrieval
get-secret "github_token"
# Output: ghp_abc123xyz

# Use in environment variables
export GITHUB_TOKEN=$(get-secret "github_token")
```

#### Delete a Secret
```bash
delete-secret "secret_name"
```

**Example**:
```bash
delete-secret "old_token"
# Output: ✓ Secret 'old_token' deleted successfully
```

#### List All Secrets
```bash
list-secrets
```

**Output**:
```
Secrets stored for user 'username':
  - github_token
  - npm_token
  - api_key
```

#### Check if Secret Exists
```bash
has-secret "secret_name"
```

**Example**:
```bash
if has-secret "github_token"; then
  echo "GitHub token is configured"
else
  echo "Please configure GitHub token"
  echo "Run: put-secret 'github_token' 'your_token'"
fi
```

**Exit codes**:
- `0` - Secret exists
- `1` - Secret not found

### Real-World Examples

#### GitHub Token Management
```bash
# Store token
put-secret "github_token" "ghp_your_personal_access_token"

# Use in your zshrc
export GITHUB_TOKEN=$(get-secret "github_token")

# Rotate token (delete old, add new)
delete-secret "github_token"
put-secret "github_token" "ghp_new_token"
```

#### NPM Authentication
```bash
# Store NPM token
put-secret "npm_token" "npm_your_token_here"

# Use in .npmrc or environment
export NPM_TOKEN=$(get-secret "npm_token")

# Or write to .npmrc
echo "//registry.npmjs.org/:_authToken=$(get-secret 'npm_token')" > ~/.npmrc
```

#### Database Credentials
```bash
# Store database password
put-secret "db_password" "super_secret_password"

# Use in connection string
export DB_URL="postgresql://user:$(get-secret 'db_password')@localhost/mydb"
```

#### API Keys
```bash
# Store various API keys
put-secret "openai_key" "sk-proj-abc123"
put-secret "aws_access_key" "AKIA..."
put-secret "stripe_key" "sk_live_..."

# Use in configuration
export OPENAI_API_KEY=$(get-secret "openai_key")
export AWS_ACCESS_KEY_ID=$(get-secret "aws_access_key")
```

## Configuration in Zsh

Add secret exports to your `~/.oh-my-zsh/custom/zshrc`:

```bash
# At the end of the file
export GITHUB_TOKEN=$(get-secret "github_token")
export NPM_TOKEN=$(get-secret "npm_token")
export OPENAI_API_KEY=$(get-secret "openai_key")
```

This configuration is **safe to commit** because secrets are retrieved from keychain, not hardcoded.

## Security Features

- **Encryption**: AES-256 encryption at rest
- **Access Control**: Requires user authentication (password or Touch ID)
- **Sandboxing**: Isolated from other applications
- **Audit Trail**: macOS logs access attempts
- **Sync**: Optional iCloud Keychain sync across devices
- **Backup**: Part of Time Machine backups (encrypted)

## How It Works

Under the hood, this plugin uses the macOS `security` command-line tool:

```bash
# Store secret
security add-generic-password -a "$USER" -s "secret_name" -w "secret_value"

# Retrieve secret
security find-generic-password -a "$USER" -s "secret_name" -w

# Delete secret
security delete-generic-password -a "$USER" -s "secret_name"
```

Secrets are stored in your login keychain at `~/Library/Keychains/login.keychain-db`.

## Best Practices

### DO ✓
- Store all API tokens and passwords using this plugin
- Use descriptive secret names (e.g., `github_token`, not `token1`)
- Rotate secrets regularly
- Test secret retrieval after storing
- Backup your keychain with Time Machine

### DON'T ✗
- Never commit actual secrets to git
- Don't share secrets via chat/email
- Don't use generic names that might conflict
- Don't forget to delete old secrets after rotation
- Don't store secrets in multiple places

## Troubleshooting

### "Secret not found" Error
```bash
# Verify secret exists
has-secret "secret_name"

# If not found, store it
put-secret "secret_name" "value"
```

### Empty Value Returned
```bash
# Check if secret is actually stored
security find-generic-password -a "$USER" -s "secret_name"

# Re-store if needed
put-secret "secret_name" "new_value"
```

### Permission Denied
- macOS will prompt for your user password
- Enter your password to grant access
- You can choose "Always Allow" to skip future prompts

### Keychain Locked
```bash
# Unlock your keychain
security unlock-keychain

# Or log out and back in
```

## Migration from Hardcoded Secrets

If you have secrets in your config files:

1. **Identify all hardcoded secrets**:
   ```bash
   grep -r "TOKEN\|KEY\|PASSWORD\|SECRET" ~/.zshrc ~/.oh-my-zsh/custom/
   ```

2. **Store each secret**:
   ```bash
   put-secret "github_token" "your_actual_token"
   put-secret "npm_token" "your_actual_token"
   ```

3. **Update your config**:
   ```bash
   # Replace this:
   export GITHUB_TOKEN="ghp_hardcoded_token"

   # With this:
   export GITHUB_TOKEN=$(get-secret "github_token")
   ```

4. **Remove hardcoded values** from all files

5. **Test in new shell**:
   ```bash
   source ~/.zshrc
   echo $GITHUB_TOKEN  # Should show your token
   ```

## Advanced Usage

### Conditional Export
```bash
# Only export if secret exists
if has-secret "github_token"; then
  export GITHUB_TOKEN=$(get-secret "github_token")
fi
```

### Default Value
```bash
# Use default if secret not found
export API_KEY=$(get-secret "api_key" || echo "default_key")
```

### Multiple Environments
```bash
# Store environment-specific secrets
put-secret "prod_db_password" "prod_pass"
put-secret "dev_db_password" "dev_pass"

# Use based on environment
if [[ "$ENV" == "production" ]]; then
  export DB_PASSWORD=$(get-secret "prod_db_password")
else
  export DB_PASSWORD=$(get-secret "dev_db_password")
fi
```

### Secret Rotation Script
```bash
#!/bin/bash
# rotate-github-token.sh

OLD_TOKEN=$(get-secret "github_token")
echo "Current token: ${OLD_TOKEN:0:10}..."

echo "Enter new token:"
read -s NEW_TOKEN

put-secret "github_token" "$NEW_TOKEN"
echo "✓ Token rotated successfully"
```

## Integration with Other Tools

### Git
```bash
export GH_TOKEN=$(get-secret "github_token")
```

### AWS CLI
```bash
export AWS_ACCESS_KEY_ID=$(get-secret "aws_access_key")
export AWS_SECRET_ACCESS_KEY=$(get-secret "aws_secret_key")
```

### Docker
```bash
export DOCKER_PASSWORD=$(get-secret "docker_password")
docker login -u username --password-stdin <<< "$DOCKER_PASSWORD"
```

### Terraform
```bash
export TF_VAR_api_token=$(get-secret "terraform_api_token")
```

## Comparison with Alternatives

| Feature | apple-secret | 1Password | pass | .env files |
|---------|--------------|-----------|------|-----------|
| macOS Native | ✓ | ✗ | ✗ | ✓ |
| Encrypted | ✓ | ✓ | ✓ | ✗ |
| No Extra Tools | ✓ | ✗ | ✗ | ✓ |
| Git Safe | ✓ | ✓ | ✓ | ⚠️ |
| Touch ID | ✓ | ✓ | ✗ | N/A |
| GUI Access | ✓ | ✓ | ✗ | ✗ |
| Cross-Platform | ✗ | ✓ | ✓ | ✓ |

## Contributing

To add new features to this plugin:

1. Edit `~/.oh-my-zsh/custom/plugins/apple-secret/apple-secret.plugin.zsh`
2. Add your function with documentation
3. Test thoroughly
4. Update this README

## Resources

- [macOS Keychain Access Guide](https://support.apple.com/guide/keychain-access/welcome/mac)
- [Security Command Manual](https://ss64.com/osx/security.html)
- [Main SECURITY.md](../SECURITY.md) - Complete security guidelines

## License

Part of custom Oh My Zsh configuration. Free to use and modify.
