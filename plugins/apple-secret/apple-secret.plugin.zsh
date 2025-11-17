# Apple Keychain Secret Management Plugin
# Provides secure secret storage using macOS Keychain

# Get a secret from keychain
# Usage: get-secret "secret_name"
# Example: export GITHUB_TOKEN=$(get-secret "github_token")
function get-secret() {
  security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null
}

# Store or update a secret in keychain
# Usage: put-secret "secret_name" "secret_value"
# Example: put-secret "github_token" "ghp_your_token_here"
function put-secret() {
  local secret_name="$1"
  local secret_value="$2"

  if [ -z "$secret_name" ] || [ -z "$secret_value" ]; then
    echo "Usage: put-secret <secret_name> <secret_value>"
    return 1
  fi

  # Check if secret already exists
  if security find-generic-password -a "$USER" -s "$secret_name" &>/dev/null; then
    # Update existing secret
    security delete-generic-password -a "$USER" -s "$secret_name" 2>/dev/null
  fi

  # Add new secret
  security add-generic-password -a "$USER" -s "$secret_name" -w "$secret_value"

  if [ $? -eq 0 ]; then
    echo "✓ Secret '$secret_name' stored successfully in keychain"
  else
    echo "✗ Failed to store secret '$secret_name'"
    return 1
  fi
}

# Delete a secret from keychain
# Usage: delete-secret "secret_name"
# Example: delete-secret "github_token"
function delete-secret() {
  local secret_name="$1"

  if [ -z "$secret_name" ]; then
    echo "Usage: delete-secret <secret_name>"
    return 1
  fi

  if security find-generic-password -a "$USER" -s "$secret_name" &>/dev/null; then
    security delete-generic-password -a "$USER" -s "$secret_name"
    if [ $? -eq 0 ]; then
      echo "✓ Secret '$secret_name' deleted successfully"
    else
      echo "✗ Failed to delete secret '$secret_name'"
      return 1
    fi
  else
    echo "✗ Secret '$secret_name' not found in keychain"
    return 1
  fi
}

# List all secrets stored by this plugin
# Usage: list-secrets
function list-secrets() {
  echo "Secrets stored for user '$USER':"
  security dump-keychain | grep -A 5 "\"acct\"<blob>=\"$USER\"" | grep "\"svce\"<blob>=" | sed 's/.*"svce"<blob>="\(.*\)"/  - \1/' | sort -u
}

# Test if a secret exists in keychain
# Usage: has-secret "secret_name"
# Example: if has-secret "github_token"; then echo "Token exists"; fi
function has-secret() {
  local secret_name="$1"

  if [ -z "$secret_name" ]; then
    echo "Usage: has-secret <secret_name>"
    return 1
  fi

  security find-generic-password -a "$USER" -s "$secret_name" &>/dev/null
  return $?
}
