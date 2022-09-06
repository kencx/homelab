terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.6"
    }
  }
}

provider "proxmox" {
  pm_api_url  = var.proxmox_ip
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}

module "server" {
  source = "../modules/vm"

  hostname    = var.hostname
  vmid        = var.vmid
  target_node = var.target_node

  template_name = var.template_name
  onboot        = var.onboot
  oncreate      = var.oncreate

  cores   = var.cores
  sockets = var.sockets
  memory  = var.memory

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}
