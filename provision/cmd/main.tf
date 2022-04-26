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

  gateway        = "${var.network_address}1"
  cmd_ip         = "${var.network_address}${var.cmd_id}"
  cmd_cidr       = "${local.cmd_ip}${var.subnet_mask}"
  cmd_drone_ip   = "${var.network_address}${var.cmd_drone_id}"
  cmd_drone_cidr = "${local.cmd_drone_ip}${var.subnet_mask}"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "cmd-core" {
  source = "../../terraform/modules/lxc"

  vm_id        = var.cmd_id
  target_node  = "pve"
  hostname     = "cmd"
  lxc_template = local.lxc_template_name
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 2
  memory = 4096
  swap   = 2048

  size                 = "10G"
  proxmox_storage_pool = "volumes"

  mounts = var.cmd_mounts

  bridge         = "vmbr1"
  ip_address     = local.cmd_cidr
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

module "cmd_drone" {
  source = "../../terraform/modules/lxc"

  vm_id        = var.cmd_drone_id
  target_node  = "pve"
  hostname     = "cmd-drone"
  lxc_template = local.lxc_template_name
  unprivileged = true
  onboot       = true
  start        = true

  cores  = 2
  memory = 4096
  swap   = 2048

  size                 = "10G"
  proxmox_storage_pool = "volumes"

  mounts = var.cmd_drone_mounts

  bridge         = "vmbr1"
  ip_address     = local.cmd_drone_cidr
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

resource "null_resource" "provisioning" {

  provisioner "local-exec" {
    command     = <<EOT
		ANSIBLE_FORCE_COLOR=1 ansible-playbook tests/pre_test.yml
	EOT
    working_dir = "./playbooks/"
  }
  depends_on = [module.cmd-core, module.cmd_drone]
}
