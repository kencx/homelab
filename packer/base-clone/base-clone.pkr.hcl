packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  ssh_public_key = file(var.ssh_public_key_path)
  template_desc  = "${var.template_description}. Created by Packer on ${formatdate("YYYY-MM-DD", timestamp())}"
  ipv4           = "${var.ip_address}/24"
}

source "proxmox-clone" "base" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  password    = var.proxmox_password
  node        = var.proxmox_node

  clone_vm                 = var.clone_vm
  full_clone               = true
  task_timeout             = "5m"
  insecure_skip_tls_verify = true

  qemu_agent              = true
  cloud_init              = true
  cloud_init_storage_pool = "volumes"

  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = local.template_desc

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

  ipconfig {
    ip      = local.ipv4
    gateway = var.gateway
  }

  ssh_host             = var.ip_address
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_timeout          = "10m"
}

build {
  sources = ["source.proxmox-clone.base"]

  # make user ssh-ready for Ansible
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline = [
      "HOME_DIR=/home/${var.ssh_username}/.ssh",
      "mkdir -m 0700 -p $HOME_DIR",
      "echo '${local.ssh_public_key}' >> $HOME_DIR/authorized_keys",
      "chown -R ${var.ssh_username}:${var.ssh_username} $HOME_DIR",
      "chmod 0600 $HOME_DIR/authorized_keys",
      "SUDOERS_FILE=/etc/sudoers.d/80-packer-users",
      "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > $SUDOERS_FILE",
      "chmod 0440 $SUDOERS_FILE",
    ]
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline = [
      # wait for cloud-init to complete
      "/usr/bin/cloud-init status --wait",
      # install and start qemu-guest-agent
      "apt update && apt install -y qemu-guest-agent ",
      "systemctl enable qemu-guest-agent.service",
      "systemctl start --no-block qemu-guest-agent.service",
    ]
    expect_disconnect = true
  }

  provisioner "ansible" {
    playbook_file = "../../ansible/common.yml"
    extra_arguments = [
      "--extra-vars",
      "user=${var.ssh_username}",
    ]
    user        = var.ssh_username
    galaxy_file = "../../requirements.yml"
    ansible_env_vars = [
      "ANSIBLE_STDOUT_CALLBACK=yaml",
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    use_proxy    = false
    pause_before = "5s"
  }
}