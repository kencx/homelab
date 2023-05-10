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

module "dev" {
  count  = 1
  source = "../modules/vm"

  hostname    = "dev"
  vmid        = 130
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores     = 1
  sockets   = 1
  memory    = 1024
  disk_size = "10G"

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}

module "dev-client" {
  count  = 1
  source = "../modules/vm"

  hostname    = "dev-client"
  vmid        = 131
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores     = 1
  sockets   = 1
  memory    = 1024
  disk_size = "15G"

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}

module "dev-control" {
  count  = 1
  source = "../modules/vm"

  hostname    = "dev-control"
  vmid        = 135
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores     = 1
  sockets   = 1
  memory    = 1024
  disk_size = "10G"

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}
