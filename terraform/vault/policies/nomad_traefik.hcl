path "kvv2/data/prod/nomad/traefik" {
  capabilities = ["read"]
}

path "pki_int/issue/client" {
  capabilities = ["create", "update", "read"]
}
