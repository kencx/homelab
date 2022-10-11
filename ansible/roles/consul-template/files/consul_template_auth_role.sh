#!/bin/bash
set -euo pipefail

CONSUL_TEMPLATE_KEY_FILE="/opt/consul-template/tls/consul_template_key.pem"
CONSUL_TEMPLATE_CERT_FILE="/opt/consul-template/tls/consul_template_cert.pem"

# generate key pair, save to file
vault write -format=json pki_int/issue/client "common_name=ctemplate" "ttl=30d" | tee \
	>(jq -r .data.private_key > "$CONSUL_TEMPLATE_KEY_FILE") \
	>(jq -r .data.certificate > "$CONSUL_TEMPLATE_CERT_FILE")

chown root:root $CONSUL_TEMPLATE_KEY_FILE $CONSUL_TEMPLATE_CERT_FILE
chmod 0600 $CONSUL_TEMPLATE_CERT_FILE
chmod 0400 $CONSUL_TEMPLATE_KEY_FILE

vault write auth/cert/certs/consul_template \
	display_name=consul_template \
	policies=consul_template \
	token_ttl=24h \
	period=20h \
	certificate=@"$CONSUL_TEMPLATE_CERT_FILE"
