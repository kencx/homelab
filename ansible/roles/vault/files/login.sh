#!/bin/bash
# https://github.com/hashicorp/consul-template/issues/318
set -euo pipefail

ADMIN_KEY_FILE="admin_key.pem"
ADMIN_CERT_FILE="admin_cert.pem"

VAULT_TOKEN="$(vault login -method=cert \
	-client-cert="$ADMIN_CERT_FILE" \
	-client-key="$ADMIN_KEY_FILE" \
	name=admin \
	-format=json \
	-no-store \
	2> /dev/null \
	| jq -r '.auth.client_token')"

exec env VAULT_TOKEN="${VAULT_TOKEN}" "${@}"
