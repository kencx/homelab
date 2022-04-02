
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
  name        = "test-vm-1"
  target_node = var.target_node

  clone   = var.vm_template_name
  os_type = "cloud-init"

  guest_agent_ready_timeout = 60 # temp workaround
  agent                     = 1  # ensure qemu_guest_agent is installed in img
  cores                     = 1
  sockets                   = 1
  memory                    = 1024
  tablet                    = false

  scsihw   = "virtio-scsi-pci"
  boot     = "c"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = "5G"
    type    = "scsi"
    storage = "volumes"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=10.10.10.101/24,gw=10.10.10.1"
  sshkeys   = <<EOF
	${var.sshkey}
	EOF
}
