
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

  gateway    = "${var.ip_block}1"
  staging_ip = "${var.ip_block}${var.staging_id}/24"
  cicd_ip    = "${var.ip_block}${var.cicd_id}/24"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "staging" {
  source = "../../terraform/modules/lxc"

  target_node  = "pve"
  vm_id        = var.staging_id
  hostname     = "staging"
  lxc_template = "local:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz"
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 2
  memory = 4096
  swap   = 2048

  size                 = "5G"
  proxmox_storage_pool = "volumes"

  ip_address     = local.staging_ip
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

module "cicd" {
  source = "../../terraform/modules/lxc"

  target_node  = "pve"
  vm_id        = var.cicd_id
  hostname     = "cicd"
  lxc_template = "local:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz"
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 1
  memory = 4096
  swap   = 2048

  size                 = "5G"
  proxmox_storage_pool = "volumes"

  ip_address     = local.cicd_ip
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      staging_ip   = local.staging_ip
      staging_user = var.staging_user
      cicd_ip      = local.cicd_ip
      cicd_user    = var.cicd_user
    }
  )
  filename = "../ansible/inventory/hosts"
}
