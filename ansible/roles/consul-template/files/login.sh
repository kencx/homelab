#!/bin/bash
# https://github.com/hashicorp/consul-template/issues/318
set -euo pipefail

KEY_FILE="/opt/consul-template/consul_template_key.pem"
CERT_FILE="/opt/consul-template/consul_template_cert.pem"

VAULT_TOKEN="$(vault login -method=cert \
	-client-cert="$CERT_FILE" \
	-client-key="$KEY_FILE" \
	-format=json \
	-no-store=true \
	2> /dev/null \
	| jq -r '.auth.client_token')"

exec env VAULT_TOKEN="${VAULT_TOKEN}" "${@}"
