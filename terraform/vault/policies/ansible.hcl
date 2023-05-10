path "pki_int/issue/auth" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/server" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/client" {
  capabilities = ["create", "update"]
}

path "auth/agent/certs/*" {
  capabilities = ["create", "update"]
}

# required to update nomad_startup auth cert
path "auth/cert/certs/nomad_startup" {
  capabilities = ["create", "update"]
}

path "kvv2/data/cluster/consul_config" {
  capabilities = ["read", "create"]
}

path "kvv2/data/cluster/nomad_config" {
  capabilities = ["read", "create"]
}
