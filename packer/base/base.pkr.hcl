packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "base" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  password    = var.proxmox_password
  node        = var.proxmox_node

  clone_vm     = "debian11-cloud"
  full_clone   = true
  task_timeout = "5m"

  insecure_skip_tls_verify = true

  vm_id   = 9000
  vm_name = "base-${formatdate("YYYY-MM-DD", timestamp())}"

  qemu_agent = true

  os              = "l26"
  cores           = var.cores
  sockets         = var.sockets
  memory          = var.memory
  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    bridge = "vmbr1"
    model  = "virtio"
  }

  vga {
    type = "serial0"
  }

  ssh_host     = "10.10.10.250"
  ssh_username = var.ssh_username
  ssh_timeout  = "10m"
}

build {
  sources = ["source.proxmox-clone.base"]

  provisioner "ansible" {
    playbook_file = "../../ansible/common.yml"
    extra_arguments = [
      "--extra-vars",
      "user=${var.ssh_username}",
    ]
    galaxy_file = "../../requirements.yml"
    user        = var.ssh_username
    ansible_env_vars = [
      "ANSIBLE_STDOUT_CALLBACK=yaml",
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
  }
}
