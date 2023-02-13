path "pki_int/issue/auth" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/server" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/client" {
  capabilities = ["create", "update"]
}

# required to self-update auth cert
path "auth/cert/certs/consul_template" {
  capabilities = ["create", "update"]
}

# manage kv secrets engine
path "kvv2/data/cluster/*" {
  capabilities = ["create", "read", "update"]
}

path "auth/token/create/nomad_cluster" {
  capabilities = ["create", "update", "sudo"]
}
