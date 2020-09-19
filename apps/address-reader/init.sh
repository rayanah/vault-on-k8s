#!/bin/bash

# Let's use colour, shall we?

export Reset='\033[0m'       # Text Reset
export Black='\033[0;30m'        # Black
export Red='\033[0;31m'          # Red
export Green='\033[0;32m'        # Green
export Yellow='\033[0;33m'       # Yellow
export Blue='\033[0;34m'         # Blue
export Purple='\033[0;35m'       # Purple
export Cyan='\033[0;36m'         # Cyan
export White='\033[0;37m'        # White

echo -e "${Green}Configuring Vault's Dynamic Database Credentials${Reset}"

export VAULT_PORT=$(kubectl get svc vault-ui -n secrets -o json | jq '.spec.ports[0].nodePort')
export VAULT_ADDR=http://localhost:$VAULT_PORT
echo -e "${Cyan}Vault Address: ${Red}${VAULT_ADDR}${Reset}"
echo -e "${Green}Logging on to vault${Reset}"
vault login root
export VAULT_TOKEN=root

echo -e "${Green}Enabling dynamic database secrets engine${Reset}"
vault secrets enable database

echo -e "${Green}Configuring vault's postgresql plugin${Reset}"
vault write database/config/my-postgresql-database \
  plugin_name=postgresql-database-plugin \
  allowed_roles="address-reader" \
  connection_url="postgresql://{{username}}:{{password}}@database-postgres:5432/" \
  username="wibble" \
  password="wobble"

echo -e "${Green}Writing address-reader role for dynamic creds${Reset}"
# Exagerated ttl here for lab purposes
vault write database/roles/address-reader \
  db_name=database-posgres \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
                       GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# kubectl apply -f . address-reader.yaml
