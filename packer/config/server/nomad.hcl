datacenter   = "dc1"
data_dir     = "/opt/nomad/data"
bind_address = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1
}

ui {
  enabled = true
}
