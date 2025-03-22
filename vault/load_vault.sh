#!/bin/zsh
echo "Loading ansible-vault secrets"
VAULT_FILE="$HOME/localdev/nid-dotfiles-ansible/vault/nidbook.yml"
VAULT_PASSWORD_FILE="$HOME/localdev/vault/ansible_vault.key"

# check if vault file exists
if [ ! -f "$VAULT_FILE" ]; then
  echo "Error: Vault file not found at $VAULT_FILE"
  exit 1
fi

# check if vault password file exists
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
  echo "Error: Vault password file not found at $VAULT_PASSWORD_FILE"
  exit 1
fi

echo "Currently loaded ansible-vault secrets:"
# extract all secrets and export them as environment variables
ansible-vault view "$VAULT_FILE" --vault-password-file="$VAULT_PASSWORD_FILE" | 
  grep -v "^#" | # Skip comment lines
  grep -v "^$" | # Skip empty lines
  grep ":" |     # Only lines with a colon
  while IFS=':' read -r key value; do
    # Trim whitespace from key and value
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs | tr -d '"')
    
    # convert snake_case to SCREAMING_SNAKE_CASE
    env_key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
    
    # export the variable
    export "$env_key"="$value"
    echo "$env_key"
  done

echo "All secrets loaded from vault successfully!"
