
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

resource "proxmox_vm_qemu" "test_vm" {
  count       = 1
  name        = var.hostname
  vmid        = var.vmid
  target_node = var.target_node

  clone      = var.vm_template_name
  full_clone = true
  os_type    = "cloud-init"

  onboot   = false
  oncreate = false

  guest_agent_ready_timeout = 60 # temp workaround
  agent                     = 1  # ensure qemu_guest_agent is installed in img
  cores                     = var.cores
  sockets                   = 1
  memory                    = var.memory
  tablet                    = false

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = var.size
    type    = "scsi"
    storage = "volumes"
  }

  network {
    model  = "virtio"
    bridge = var.bridge
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=10.10.10.101/24,gw=10.10.10.1"
  sshkeys   = <<EOF
	${var.ssh_public_key}
	EOF
}
