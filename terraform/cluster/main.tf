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

module "server" {
  source = "../modules/vm"
  for_each = {
    for idx, vm in var.servers : idx + 1 => vm
  }

  hostname    = "server-${each.key}"
  vmid        = each.value.id
  tags        = var.tags
  target_node = var.target_node

  clone_template_id = var.template_id
  onboot            = var.onboot
  started           = var.started

  cores   = each.value.cores
  sockets = each.value.sockets
  memory  = each.value.memory

  disk_size      = each.value.disk_size
  disk_datastore = var.disk_datastore

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_public_keys = [file(var.ssh_public_key_file)]
}

module "client" {
  source = "../modules/vm"
  for_each = {
    for idx, vm in var.clients : idx + 1 => vm
  }

  hostname    = "client-${each.key}"
  vmid        = each.value.id
  tags        = var.tags
  target_node = var.target_node

  clone_template_id = var.template_id
  onboot            = var.onboot
  started           = var.started

  cores   = each.value.cores
  sockets = each.value.sockets
  memory  = each.value.memory

  disk_size      = each.value.disk_size
  disk_datastore = var.disk_datastore

  ip_address = each.value.ip_address
  ip_gateway = var.ip_gateway

  ssh_user        = var.ssh_user
  ssh_public_keys = [file(var.ssh_public_key_file)]
}

resource "local_file" "tf_ansible_inventory_file" {
  content         = <<-EOF
[server]
%{for vm in var.servers~}
${split("/", vm.ip_address)[0]}
%{endfor~}

[client]
%{for vm in var.clients~}
${split("/", vm.ip_address)[0]}
%{endfor~}

[prod]
%{for vm in var.servers~}
${split("/", vm.ip_address)[0]}
%{endfor~}
%{for vm in var.clients~}
${split("/", vm.ip_address)[0]}
%{endfor~}
EOF
  filename        = "${path.module}/tf_ansible_inventory"
  file_permission = "0644"
}
