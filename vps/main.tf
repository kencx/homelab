terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.35"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

variable "hcloud_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "ssh_key_path" {
  type        = string
  description = "Path to SSH public key"
}

output "ip_address" {
  value       = hcloud_server.main.ipv4_address
  description = "IP address of endpoint"
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
  user_data = file("./cloud-config")
}
