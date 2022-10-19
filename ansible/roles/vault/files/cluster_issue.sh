#!/bin/bash

mkdir -p "$HOME/certs"

output=$(vault write -format=json "pki_int/issue/cluster" "common_name=$1" "ttl=24h")
echo "$output" | jq -r '.data.certificate' > "$HOME/certs/$1-cert.crt"
echo "$output" | jq -r '.data.private_key' > "$HOME/certs/$1-key.pem"
echo "$output" | jq -r '.data.issuing_ca' > "$HOME/certs/$1-ca.crt"
