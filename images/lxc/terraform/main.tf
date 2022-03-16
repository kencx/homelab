
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

locals {
  proxmox_api_url = "https://${var.proxmox_ip}:8006/api2/json"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "base_lxc" {
  source = "../../../terraform/modules/lxc"

  target_node  = "pve"
  vm_id        = var.vm_id
  hostname     = "base-lxc"
  lxc_template = var.base_template
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 1
  memory = 4096
  swap   = 2048

  size                 = "5G"
  proxmox_storage_pool = "volumes"

  ip_address      = "10.10.10.254/24"
  gateway         = "10.10.10.1"
  ssh_public_keys = tls_private_key.temp_private_key.public_key_openssh
}

resource "tls_private_key" "temp_private_key" {
  algorithm = "RSA"
}


resource "null_resource" "provisioning" {

  provisioner "local-exec" {
    inline = [
      "echo LXC up!"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo LXC connected!"
    ]

    connection {
      type        = "ssh"
      host        = "var.ip_address"
      user        = var.user
      private_key = tls_private_key.temp_private_key.private_key_pem
    }
  }
}
