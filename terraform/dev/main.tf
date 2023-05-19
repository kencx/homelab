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

locals {
  servers = {
    for idx, val in var.server_vmid : val => {
      index      = idx + 1,
      ip_address = var.server_ip_address[idx],
    }
  }
  clients = {
    for idx, val in var.client_vmid : val => {
      index      = idx + 1,
      ip_address = var.client_ip_address[idx],
    }
  }
}

module "dev" {
  source   = "../modules/vm"
  for_each = local.servers

  hostname    = "${var.server_hostname_prefix}-${each.value.index}"
  vmid        = parseint(each.key, 10)
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores   = var.server_cores
  sockets = var.server_sockets
  memory  = var.server_memory

  disk_size         = var.server_disk_size
  disk_storage_pool = var.disk_storage_pool

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}

module "dev-client" {
  source   = "../modules/vm"
  for_each = local.clients

  hostname    = "${var.client_hostname_prefix}-${each.value.index}"
  vmid        = parseint(each.key, 10)
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores   = var.client_cores
  sockets = var.client_sockets
  memory  = var.client_memory

  disk_size         = var.client_disk_size
  disk_storage_pool = var.disk_storage_pool

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}

module "dev-control" {
  source = "../modules/vm"
  count  = 1

  hostname    = "${var.server_hostname_prefix}-control"
  vmid        = 135
  tags        = var.tags
  target_node = var.target_node

  clone_template_name = var.template_name
  onboot              = var.onboot
  oncreate            = var.oncreate

  cores             = 1
  sockets           = 1
  memory            = 1024
  disk_size         = "10G"
  disk_storage_pool = var.disk_storage_pool

  ip_address = var.control_ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_private_key = file(var.ssh_private_key_file)
  ssh_public_key  = file(var.ssh_public_key_file)
}
