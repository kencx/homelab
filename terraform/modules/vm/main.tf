
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.6"
    }
  }
}

resource "proxmox_vm_qemu" "base" {
  name = var.hostname
  vmid = var.vmid

  target_node = var.target_node

  clone      = var.template_name
  full_clone = true

  onboot   = var.onboot
  oncreate = var.oncreate
  tablet   = false
  agent    = 1 # ensure qemu_guest_agent is installed in img

  qemu_os = "l26"
  cores   = var.cores
  sockets = var.sockets
  memory  = var.memory
  scsihw  = "virtio-scsi-pci"

  lifecycle {
    ignore_changes = [
      network,
      disk
    ]
  }

  os_type         = "cloud-init"
  ssh_user        = var.ssh_user
  ssh_private_key = <<EOF
${var.ssh_private_key}
EOF
  ci_wait         = 60
  ciuser          = var.ssh_user
  sshkeys         = var.ssh_public_key
  ipconfig0       = "ip=10.10.10.${var.vmid}/24,gw=10.10.10.1"

  connection {
    type = "ssh"
    user = var.ssh_user
    host = self.ssh_host
  }

  provisioner "remote-exec" {
    inline = [
      "echo Hello World!",
      "ip -br a"
    ]
  }
}
