#!/bin/bash
set -euo pipefail

CONSUL_TEMPLATE_KEY_FILE="/opt/consul-template/tls/consul_template_key.pem"
CONSUL_TEMPLATE_CERT_FILE="/opt/consul-template/tls/consul_template_cert.pem"

# generate key pair, save to file
vault write -format=json pki_int/issue/client "common_name=ctemplate" "ttl=30d" | tee \
	>(jq -r .data.private_key > "$CONSUL_TEMPLATE_KEY_FILE") \
	>(jq -r .data.certificate > "$CONSUL_TEMPLATE_CERT_FILE")

vault write auth/cert/certs/consul_template \
	display_name=consul_template \
	policies=consul_template \
	ttl=2h \
	max_ttl=24h \
	certificate=@"$CONSUL_TEMPLATE_CERT_FILE"
