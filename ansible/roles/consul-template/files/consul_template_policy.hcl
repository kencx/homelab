
path "pki_int/issue/cluster" {
  capabilities = ["create", "update"]
}

# TODO replace with ctemplate role
path "pki_int/issue/client" {
  capabilities = ["create", "update"]
}

# required to self-update auth cert
path "auth/cert/certs/consul_template" {
  capabilities = ["create", "update"]
}

# manage kv secrets engine
path "kv/data/cluster/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
