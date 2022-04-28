
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

resource "proxmox_lxc" "lxc" {
  target_node = var.target_node
  vmid        = var.vm_id
  hostname    = var.hostname

  ostemplate   = var.lxc_template
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start

  password = random_password.password.result

  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  features {
    nesting = true
    mount   = "nfs" # only allowed if unprivileged = false
  }

  # mandatory
  rootfs {
    storage = var.proxmox_storage_pool
    size    = var.size
  }

  dynamic "mountpoint" {
    for_each = var.mounts

    content {
      key     = mountpoint.value.key
      slot    = mountpoint.value.slot
      storage = mountpoint.value.host_mountpoint
      volume  = mountpoint.value.host_mountpoint
      mp      = mountpoint.value.lxc_mountpoint
      size    = mountpoint.value.mp_size
    }
  }

  network {
    name   = "eth0"
    bridge = var.bridge
    ip     = var.ip_address
    gw     = var.gateway
  }

  ssh_public_keys = <<EOF
	${var.ssh_public_key}
	EOF
}

resource "random_password" "password" {
  length  = 20
  special = true
}
