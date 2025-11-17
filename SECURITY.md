# Security Best Practices

## ✓ Current Implementation: Apple Keychain Secret Management

You have successfully implemented secure secret management using the **apple-secret** plugin!

### Current Setup (custom/zshrc lines 39-40)
```bash
export GITHUB_TOKEN=$(get-secret "github_token")
export NPM_TOKEN=$(get-secret "npm_token")
```

This approach:
- ✓ Stores secrets securely in macOS Keychain
- ✓ Never exposes secrets in configuration files
- ✓ Safe to commit to version control
- ✓ Integrates seamlessly with your shell

---

## ⚠️ Legacy Issue: Exposed Token in Main .zshrc

**Status**: NEEDS CLEANUP

Your main `~/.zshrc` file still contains an exposed GitHub token:
```bash
# Line 123 in ~/.zshrc
export GITHUB_TOKEN=#######
```

### Required Actions
1. **Revoke the old token**: Go to https://github.com/settings/tokens
2. **Delete lines 123-124** from `~/.zshrc` (not needed anymore - using apple-secret instead)
3. **Remove FNM lines 119-122** from `~/.zshrc` (moved to custom/plugins/envs)

---

## Apple Secret Plugin - Complete Guide

### Available Commands

#### 1. Store a Secret
```bash
put-secret "github_token" "ghp_your_new_token_here"
put-secret "npm_token" "npm_your_token_here"
put-secret "api_key" "your_api_key_here"
```

Output: `✓ Secret 'github_token' stored successfully in keychain`

#### 2. Retrieve a Secret
```bash
# In shell (manual retrieval)
get-secret "github_token"

# In configuration (auto-export)
export GITHUB_TOKEN=$(get-secret "github_token")
export NPM_TOKEN=$(get-secret "npm_token")
```

#### 3. Delete a Secret
```bash
delete-secret "old_token"
```

Output: `✓ Secret 'old_token' deleted successfully`

#### 4. List All Secrets
```bash
list-secrets
```

Output:
```
Secrets stored for user 'giorgiosaud':
  - github_token
  - npm_token
  - api_key
```

#### 5. Check if Secret Exists
```bash
if has-secret "github_token"; then
  echo "Token is configured"
else
  echo "Token missing - please configure"
fi
```

### Setup New Secrets

**Step 1**: Generate a new GitHub token
- Go to https://github.com/settings/tokens
- Click "Generate new token (classic)" or "Fine-grained token"
- Select minimal required scopes (repo, workflow, etc.)
- Copy the token

**Step 2**: Store it securely
```bash
put-secret "github_token" "ghp_your_new_token_here"
```

**Step 3**: Verify it works
```bash
# Test retrieval
get-secret "github_token"

# Test in a new shell
source ~/.zshrc
echo $GITHUB_TOKEN  # Should show your token
```

**Step 4**: Clean up old hardcoded tokens
```bash
# Remove from ~/.zshrc (lines 119-124)
# Keep only: source ~/.oh-my-zsh/custom/zshrc
```

### Security Features

**Encryption**: macOS Keychain uses AES-256 encryption
**Access Control**: Requires your user password or Touch ID
**Sandboxing**: Each app can only access authorized keychain items
**Backup**: Keychain syncs via iCloud Keychain (optional)
**Audit Trail**: macOS logs keychain access attempts

### Alternative Options (If Not Using apple-secret)

#### Option 1: GitHub CLI
```bash
brew install gh
gh auth login  # Opens browser for OAuth
```

#### Option 2: 1Password CLI
```bash
export GITHUB_TOKEN=$(op read "op://Private/GitHub Token/credential")
```

#### Option 3: Pass (Unix password manager)
```bash
export GITHUB_TOKEN=$(pass show github/token)
```

---

## Best Practices

### DO ✓
- ✓ Use `apple-secret` plugin for all credentials
- ✓ Store secrets in keychain before exporting
- ✓ Rotate tokens regularly (set expiration dates)
- ✓ Use minimal scopes on tokens
- ✓ Test secret retrieval in new shells
- ✓ Commit your custom zsh configuration safely
- ✓ Use fine-grained GitHub tokens when possible

### DON'T ✗
- ✗ Never hardcode secrets in any config file
- ✗ Never commit `.env` files with secrets
- ✗ Never echo or log secret values
- ✗ Never share keychain password
- ✗ Never store secrets in plain text anywhere
- ✗ Never commit to public repos with exposed secrets

---

## Troubleshooting

### Secret Not Found
```bash
# Check if secret exists
has-secret "github_token"

# If not found, add it
put-secret "github_token" "your_token_here"
```

### Permission Denied
```bash
# macOS might prompt for password - this is normal
# Enter your user password to grant keychain access
```

### Token Not Working
```bash
# Verify token is retrieved
get-secret "github_token"

# Check it's exported
echo $GITHUB_TOKEN

# Reload shell
source ~/.zshrc
```

### Keychain Locked
```bash
# Unlock keychain (will prompt for password)
security unlock-keychain

# Or restart and log in again
```

---

## Migration Checklist

- [ ] Generate new GitHub token with appropriate scopes
- [ ] Store new token: `put-secret "github_token" "new_token"`
- [ ] Verify retrieval: `get-secret "github_token"`
- [ ] Test in new shell: `source ~/.zshrc && echo $GITHUB_TOKEN`
- [ ] Revoke old exposed token on GitHub
- [ ] Delete lines 119-124 from `~/.zshrc`
- [ ] Test git operations still work
- [ ] Store NPM token: `put-secret "npm_token" "your_npm_token"`
- [ ] Commit updated custom folder to your repo
- [ ] Document any additional secrets needed

---

## Why This Approach is Secure

**Comparison**:

| Method | Security | Convenience | Version Control Safe |
|--------|----------|-------------|---------------------|
| Hardcoded in files | ✗ Poor | ✓ Easy | ✗ No |
| .env files | ⚠️ Moderate | ✓ Easy | ⚠️ With .gitignore |
| GitHub CLI | ✓ Good | ✓ Easy | ✓ Yes |
| **apple-secret** | ✓✓ Excellent | ✓✓ Easy | ✓✓ Yes |
| 1Password CLI | ✓✓ Excellent | ⚠️ Moderate | ✓✓ Yes |

**apple-secret advantages**:
- Native macOS integration
- No additional tools needed
- Simple API (get/put/delete)
- Encrypted at rest
- Protected by user password/Touch ID
- Survives system restarts
- Safe to commit zsh config

---

## Additional Resources

- [macOS Keychain Services](https://support.apple.com/guide/keychain-access/welcome/mac)
- [GitHub Token Scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
- [Fine-grained Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Security Command Reference](https://ss64.com/osx/security.html)
