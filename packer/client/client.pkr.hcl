
source "proxmox-clone" "client" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  password    = var.proxmox_password
  node        = var.proxmox_node

  clone_vm     = var.clone_vm
  full_clone   = true
  task_timeout = "5m"

  insecure_skip_tls_verify = true

  vm_id   = var.vm_id
  vm_name = "client-${formatdate("YYYY-MM-DD", timestamp())}"

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

  ssh_host     = "10.10.10.251"
  ssh_username = var.ssh_username
  ssh_timeout  = "10m"
}

build {
  sources = ["source.proxmox-clone.client"]

  provisioner "ansible" {
    playbook_file = "../../ansible/playbooks/client.yml"
    user          = var.ssh_username
    galaxy_file  = "../../requirements.yml"
    pause_before  = "3s"
    ansible_env_vars = [
      "ANSIBLE_STDOUT_CALLBACK=yaml"
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
  }
}
