
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

  lxc_template_name = "local:vztmpl/${var.lxc_template_name}"
  gateway           = "${var.ip_block}1"
  core_ip           = "${var.ip_block}${var.core_id}/24"
  apps_ip           = "${var.ip_block}${var.apps_id}/24"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "core" {
  source = "../../terraform/modules/lxc"

  target_node  = "pve"
  vm_id        = var.core_id
  hostname     = "${var.environment}-core"
  lxc_template = local.lxc_template_name
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 2
  memory = 4096
  swap   = 2048

  size                 = "10G"
  proxmox_storage_pool = "volumes"

  bridge         = "vmbr1"
  ip_address     = local.core_ip
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

module "apps" {
  source = "../../terraform/modules/lxc"

  target_node  = "pve"
  vm_id        = var.apps_id
  hostname     = "${var.environment}-apps"
  lxc_template = local.lxc_template_name
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 2
  memory = 8192
  swap   = 2048

  size                 = "30G"
  proxmox_storage_pool = "volumes"

  bridge         = "vmbr1"
  ip_address     = local.apps_ip
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

# module "vault" {
#   source = "../../terraform/modules/lxc"
#   count  = 0
#
#   target_node  = "pve"
#   vm_id        = var.vault_id
#   hostname     = "${var.environment}-vault"
#   lxc_template = local.lxc_template_name
#   unprivileged = true
#   onboot       = true
#   start        = true
#
#   cores  = 2
#   memory = 4096
#   swap   = 2048
#
#   size                 = "5G"
#   proxmox_storage_pool = "volumes"
#
#   bridge         = "vmbr1"
#   ip_address     = local.vault_ip
#   gateway        = local.gateway
#   ssh_public_key = var.ssh_public_key
# }

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      core_ip   = local.core_ip
      core_user = var.core_user
      apps_ip   = local.apps_ip
      apps_user = var.apps_user
    }
  )
  filename = "../playbooks/inventory/hosts"
}
