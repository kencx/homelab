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
  controller_ip     = "${var.ip_block}${var.controller_id}"
  controller_cidr   = "${local.controller_ip}/24"
}

provider "proxmox" {
  pm_api_url      = local.proxmox_api_url
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "controller" {
  source = "../../terraform/modules/lxc"

  vm_id        = var.controller_id
  target_node  = "pve"
  hostname     = "controller"
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
  ip_address     = local.controller_cidr
  gateway        = local.gateway
  ssh_public_key = var.ssh_public_key
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      controller_ip       = local.controller_ip
      controller_user     = var.controller_user
      github_access_token = var.github_access_token
    }
  )
  filename   = "./playbooks/inventory/hosts.yml"
  depends_on = [module.controller]
}

resource "null_resource" "provisioning" {

  provisioner "local-exec" {
    command     = <<EOT
		echo LXC up!
		ANSIBLE_FORCE_COLOR=1 ansible-playbook controller.yml -K
	EOT
    working_dir = "./playbooks/"
  }
  depends_on = [module.controller, resource.local_file.ansible_inventory]
}

