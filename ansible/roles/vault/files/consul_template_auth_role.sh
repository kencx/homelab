#!/bin/bash
set -e

# TODO pass ansible variables
CONSUL_TEMPLATE_KEY_FILE="consul_template_key.pem"
CONSUL_TEMPLATE_CERT_FILE="consul_template_cert.pem"

# generate key pair, save to file
vault write -format=json pki_int/issue/client "common_name=consul_template" "ttl=365d" | tee \
	>(jq -r .data.private_key > "$CONSUL_TEMPLATE_KEY_FILE") \
	>(jq -r .data.certificate > "$CONSUL_TEMPLATE_CERT_FILE")

# add certificate to auth/cert
# todo change ttl
vault write auth/cert/certs/consul_template \
	display_name=consul_template \
	policies=consul_template \
	ttl=3600 \
	certificate=@consul_template_cert.pem
