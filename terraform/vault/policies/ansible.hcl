path "pki_int/issue/auth" {
  capabilities = ["create", "update"]
}

path "auth/cert/certs/agent" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/server" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/client" {
  capabilities = ["create", "update"]
}

path "kvv2/data/cluster/consul_config" {
  capabilities = ["read", "create"]
}

path "kvv2/data/cluster/nomad_config" {
  capabilities = ["read", "create"]
}

path "auth/token/create/nomad_cluster" {
  capabilities = ["create", "update", "sudo"]
}
