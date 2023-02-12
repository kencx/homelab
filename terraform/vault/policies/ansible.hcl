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
