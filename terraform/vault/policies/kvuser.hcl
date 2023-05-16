path "kvv2/data/prod/*" {
  capabilities = ["create", "read", "update", "delete", "patch"]
}

path "kvv2/data/prod" {
  capabilities = ["list"]
}

path "kvv2/data/dev/*" {
  capabilities = ["create", "read", "update", "delete", "patch"]
}

path "kvv2/data/dev" {
  capabilities = ["list"]
}
