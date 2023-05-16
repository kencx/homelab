terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url  = var.proxmox_ip
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}

module "server" {
  count  = 1
  source = "../modules/vm"

  hostname    = "server-1"
  vmid        = 110
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores     = 2
  sockets   = 2
  memory    = 2048
  disk_size = "10G"

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}

module "client" {
  count  = 1
  source = "../modules/vm"

  hostname    = "client-1"
  vmid        = 111
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores     = 2
  sockets   = 2
  memory    = 8192
  disk_size = "15G"

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}
