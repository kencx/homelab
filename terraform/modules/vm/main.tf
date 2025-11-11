terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.36.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.hostname
  vm_id       = var.vmid
  description = "Managed by Terraform"
  tags        = var.tags

  node_name = var.target_node
  on_boot   = var.onboot
  started   = var.started

  agent {
    type = "virtio"
    # ensure qemu_guest_agent is installed in template/img/vm
    enabled = true
  }

  tablet_device = false

  cpu {
    cores   = var.cores
    sockets = var.sockets
  }

  disk {
    interface    = "scsi0"
    datastore_id = var.disk_datastore
    size         = var.disk_size
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge = "vmbr1"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  clone {
    datastore_id = var.disk_datastore
    vm_id        = var.clone_template_id
    retries      = 3
  }

  vga {
    memory  = 16
    type    = "serial0"
  }

  initialization {
    datastore_id = var.disk_datastore
    interface    = "ide0"

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.ip_gateway
      }
    }

    user_account {
      username = var.ssh_user
      keys     = var.ssh_public_keys
    }
  }

  lifecycle {
    ignore_changes = [
      # temp fix for SSH keys
      # https://github.com/bpg/terraform-provider-proxmox/issues/373
      initialization[0].user_account
    ]
  }
}
