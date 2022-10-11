#!/bin/bash
set -e

ADMIN_KEY_FILE="/opt/vault/tls/admin_key.pem"
ADMIN_CERT_FILE="/opt/vault/tls/admin_cert.pem"

# generate key pair, save to file
vault write -format=json pki_int/issue/client "common_name=admin" "ttl=365d" | tee \
	>(jq -r .data.private_key > "$ADMIN_KEY_FILE") \
	>(jq -r .data.certificate > "$ADMIN_CERT_FILE")

chown vault:vault $ADMIN_KEY_FILE $ADMIN_CERT_FILE
chmod 0600 $ADMIN_CERT_FILE
chmod 0400 $ADMIN_KEY_FILE

# add certificate to auth/cert
# each login instance last for 2h by default,
# can be renewed up to 1d
vault write auth/cert/certs/admin \
	display_name=admin \
	token_policies=admin \
	token_ttl=2h \
	token_max_ttl=24h \
	certificate=@"$ADMIN_CERT_FILE"
