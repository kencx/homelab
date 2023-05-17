terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.38"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "main" {
  name       = "webserver"
  public_key = file(var.ssh_key_path)
}

resource "hcloud_server" "main" {
  name        = "webserver"
  image       = "debian-11"
  server_type = "cx11"
  location    = "nbg1"

  ssh_keys  = [hcloud_ssh_key.main.id]
  user_data = file(var.cloud_config_path)
}

output "ip_address" {
  value       = hcloud_server.main.ipv4_address
  description = "IP address of endpoint"
}
