terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.36.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_ip
  api_token = var.proxmox_api_token
  insecure  = true
  ssh {
    agent = true
  }
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

  clone_template_id = var.template_id
  onboot            = var.onboot
  started           = var.started

  cores   = var.server_cores
  sockets = var.server_sockets
  memory  = var.server_memory

  disk_size      = var.server_disk_size
  disk_datastore = var.disk_datastore

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_public_keys = [file(var.ssh_public_key_file)]
}

module "dev-client" {
  source   = "../modules/vm"
  for_each = local.clients

  hostname    = "${var.client_hostname_prefix}-${each.value.index}"
  vmid        = parseint(each.key, 10)
  tags        = var.tags
  target_node = var.target_node

  clone_template_id = var.template_id
  onboot            = var.onboot
  started           = var.started

  cores   = var.client_cores
  sockets = var.client_sockets
  memory  = var.client_memory

  disk_size      = var.server_disk_size
  disk_datastore = var.disk_datastore

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_public_keys = [file(var.ssh_public_key_file)]
}

module "dev-control" {
  source = "../modules/vm"
  count  = 1

  hostname    = "${var.server_hostname_prefix}-control"
  vmid        = 135
  tags        = var.tags
  target_node = var.target_node

  clone_template_id = var.template_id
  onboot            = var.onboot
  started           = var.started

  cores   = 1
  sockets = 1
  memory  = 1024

  disk_size      = 10
  disk_datastore = var.disk_datastore

  ip_address = var.control_ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_public_keys = [file(var.ssh_public_key_file)]
}
