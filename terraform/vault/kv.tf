resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  description = "KV version 2 secrets engine"
  options = {
    version = "2"
  }
}
