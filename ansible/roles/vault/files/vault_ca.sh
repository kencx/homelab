#!/bin/bash

set -e

vault secrets enable kv

# Root CA
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# Generate root certificate
root_cert=$(vault write -field=certificate pki/root/generate/internal \
	common_name="Root CA" \
	ttl=87600h)
vault write pki/config/urls \
	issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
	crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
echo "Root CA generated"

# Intermediate CA
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int

# Generate intermediate CSR
intermediate_csr=$(vault write -format=json pki_int/intermediate/generate/internal \
	common_name="Intermediate CA" \
	| jq -r '.data.csr')

# Sign intermediate CSR to generate certificate
intermediate=$(vault write -format=json pki/root/sign-intermediate csr="$intermediate_csr" \
	format=pem_bundle ttl="43800h" \
	| jq -r '.data.certificate')

# import intermediate certificate to Vault
vault write pki_int/intermediate/set-signed certificate="$intermediate"
echo "Intermediate certificate generated"

# create role
vault write pki_int/roles/consul-dc1 \
	allowed_domains="localhost,dc1.consul,dc1.nomad,global.nomad" \
	allow_subdomains=true \
	generate_lease=true \
	max_ttl="720h"
echo "Intermediate CA role created"
