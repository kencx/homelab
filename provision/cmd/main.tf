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

  gateway        = "${var.ip_address}1"
  cmd_ip         = "${var.ip_address}${var.cmd_id}"
  cmd_cidr       = "${local.cmd_ip}${var.subnet_mask}"
  cmd_drone_ip   = "${var.ip_address}${var.cmd_drone_id}"
  cmd_drone_cidr = "${local.cmd_drone_ip}${var.subnet_mask}"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

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

  bridge         = "vmbr1"
  ip_address     = local.cmd_drone_cidr
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      cmd_ip              = local.cmd_ip
      cmd_user            = var.cmd_user
      cmd_drone_ip        = local.cmd_drone_ip
      cmd_drone_user      = var.cmd_drone_user
      github_access_token = var.github_access_token
    }
  )
  filename   = "./playbooks/inventory/hosts.yml"
  depends_on = [module.cmd-core, module.cmd_drone]
}

resource "null_resource" "provisioning" {

  provisioner "local-exec" {
    command     = <<EOT
		ansible-galaxy -f -r ../../requirements.yml
		ANSIBLE_FORCE_COLOR=1 ansible-playbook main.yml -K
	EOT
    working_dir = "./playbooks/"
  }
  depends_on = [module.cmd-core, module.cmd_drone, resource.local_file.ansible_inventory]
}
