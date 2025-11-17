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

# Validate GitHub token
# Usage: validate-github-token
function validate-github-token() {
  local token=$(get-secret "github_token")

  if [ -z "$token" ]; then
    echo "✗ No GitHub token found in keychain"
    return 1
  fi

  echo "Validating GitHub token..."
  local response=$(curl -s -w "%{http_code}" -o /dev/null -H "Authorization: token $token" https://api.github.com/user)

  if [ "$response" = "200" ]; then
    local user=$(curl -s -H "Authorization: token $token" https://api.github.com/user | grep -o '"login": *"[^"]*"' | sed 's/"login": *"\(.*\)"/\1/')
    echo "✓ GitHub token is valid (user: $user)"
    return 0
  else
    echo "✗ GitHub token is invalid or expired (HTTP $response)"
    return 1
  fi
}

# Check secret age and warn if old
# Usage: check-secret-age "secret_name" [days_threshold]
# Example: check-secret-age "github_token" 90
function check-secret-age() {
  local secret_name="$1"
  local threshold="${2:-90}"  # Default: 90 days

  if ! has-secret "$secret_name"; then
    echo "✗ Secret '$secret_name' not found"
    return 1
  fi

  # Get secret modification date (macOS specific)
  local mod_date=$(security find-generic-password -a "$USER" -s "$secret_name" 2>/dev/null | grep "mdat" | sed 's/.*"\(.*\)".*/\1/')

  if [ -z "$mod_date" ]; then
    echo "⚠️  Cannot determine age of secret '$secret_name'"
    return 0
  fi

  local secret_timestamp=$(date -j -f "%Y%m%d%H%M%SZ" "$mod_date" +%s 2>/dev/null)
  local now=$(date +%s)
  local age_days=$(( (now - secret_timestamp) / 86400 ))

  if [ $age_days -gt $threshold ]; then
    echo "⚠️  Secret '$secret_name' is $age_days days old (threshold: $threshold days)"
    echo "   Consider rotating this secret"
    return 1
  else
    echo "✓ Secret '$secret_name' is $age_days days old (within threshold)"
    return 0
  fi
}

# Rotate a secret (helper function)
# Usage: rotate-secret "secret_name"
function rotate-secret() {
  local secret_name="$1"

  if [ -z "$secret_name" ]; then
    echo "Usage: rotate-secret <secret_name>"
    return 1
  fi

  echo "Rotating secret: $secret_name"
  echo "Current value: $(get-secret "$secret_name" | sed 's/\(.\{10\}\).*/\1.../')"
  echo ""
  echo "Enter new value for '$secret_name':"
  read -s new_value

  if [ -z "$new_value" ]; then
    echo "✗ No value provided, rotation cancelled"
    return 1
  fi

  put-secret "$secret_name" "$new_value"
  echo "✓ Secret '$secret_name' rotated successfully"
}

# Check all secrets for age
# Usage: check-all-secrets [days_threshold]
function check-all-secrets() {
  local threshold="${1:-90}"

  echo "Checking all secrets (threshold: $threshold days)..."
  echo ""

  list-secrets | grep "  - " | sed 's/  - //' | while read secret; do
    check-secret-age "$secret" "$threshold"
    echo ""
  done
}
