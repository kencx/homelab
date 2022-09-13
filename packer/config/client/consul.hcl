datacenter  = "dc1"
data_dir    = "/opt/consul"
bind_addr   = "{{ GetInterfaceIP \"eth0\" }}"
client_addr = "0.0.0.0"

server     = false
start_join = ["10.10.10.201"]

ui_config {
  enabled = true
}
