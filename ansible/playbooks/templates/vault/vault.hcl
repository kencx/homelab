storage "raft" {
  path    = "/opt/vault/data"
  node_id = "server-1" # hostname
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/cert.pem"
  tls_key_file  = "/opt/vault/tls/key.pem"
}

api_addr     = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui           = true

service_registration "consul" {
  address = "127.0.0.1:8500"
}
