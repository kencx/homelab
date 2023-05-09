path "pki_int/issue/auth" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/server" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/client" {
  capabilities = ["create", "update"]
}

# required to update vault agent auth cert
path "auth/agent/certs/*" {
  capabilities = ["create", "update"]
}

# required to update nomad_startup auth cert
path "auth/cert/certs/nomad_startup" {
  capabilities = ["create", "update"]
}

# manage kv secrets engine
path "kvv2/data/cluster/*" {
  capabilities = ["create", "read", "update"]
}
