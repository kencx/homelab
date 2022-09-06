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

  clone_vm     = var.clone_vm
  full_clone   = true
  task_timeout = "5m"

  insecure_skip_tls_verify = true

  vm_id   = var.vm_id
  vm_name = "base-${formatdate("YYYY-MM-DD", timestamp())}"

  qemu_agent = true
  cloud_init = true

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

  provisioner "shell" {
    script = "./scripts/base.sh"
  }

  /* provisioner "ansible-remote" { */
  /*   playbook_file    = "./scripts/base.yml" */
  /*   ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_STDOUT_CALLBACK=yaml"] */
  /*   galaxy_file      = "../requirements.yml" */
  /* } */
}
