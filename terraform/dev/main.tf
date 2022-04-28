
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

locals {
  proxmox_api_url   = "https://${var.proxmox_ip}:8006/api2/json"
  lxc_template_name = "local:vztmpl/${var.lxc_template_name}"

  gateway    = "${var.network_address}1"
  ip_address = "${var.network_address}${var.vmid}${var.subnet_mask}"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "apps" {
  source = "../modules/lxc"

  vm_id        = var.vmid
  target_node  = "pve"
  hostname     = "${var.environment}-apps"
  lxc_template = local.lxc_template_name
  unprivileged = false
  onboot       = true
  start        = true

  cores  = 2
  memory = 4096
  swap   = 2048

  size                 = "10G"
  proxmox_storage_pool = "volumes"

  mounts = var.mounts

  bridge         = "vmbr1"
  ip_address     = local.ip_address
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}
