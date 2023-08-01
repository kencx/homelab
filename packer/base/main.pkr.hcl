packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  preseed = {
    username      = var.ssh_username
    password      = var.ssh_password
    root_password = var.root_password
  }
  ssh_public_key = file(var.ssh_public_key_path)
}

source "qemu" "base" {
  vm_name          = var.vm_name
  headless         = true
  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  cpus      = 2
  disk_size = "65536"
  memory    = 1024
  qemuargs = [
    ["-m", "1024M"],
    ["-bios", "bios-256k.bin"],
    ["-display", "none"]
  ]

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_wait_timeout     = "3600s"

  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/http/preseed.pkrtpl", local.preseed)
  }
  boot_wait    = "5s"
  boot_command = ["<esc><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><enter><wait>"]
}

source "proxmox-iso" "base" {
  proxmox_url = var.proxmox_url
  username    = var.proxmox_username
  password    = var.proxmox_password
  node        = var.proxmox_node

  iso_file = "local:iso/debian-11.5.0-amd64-netinst.iso"
  /* iso_url          = var.iso_url */
  iso_checksum     = var.iso_checksum
  iso_storage_pool = "local"
  unmount_iso      = true

  task_timeout             = "3m"
  insecure_skip_tls_verify = true

  vm_id   = var.vm_id
  vm_name = "${var.vm_name}-${formatdate("YYYY-MM-DD", timestamp())}"

  qemu_agent              = true
  cloud_init              = true
  cloud_init_storage_pool = "volumes"

  os              = "l26"
  cores           = var.cores
  sockets         = var.sockets
  memory          = var.memory
  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    bridge = "vmbr1"
    model  = "virtio"
  }

  disks {
    type              = "scsi"
    disk_size         = "5G"
    storage_pool      = "volumes"
    storage_pool_type = "lvm-thin"
    format            = "raw"
  }

  ssh_host             = "10.10.10.250"
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_timeout          = "3600s"

  http_interface = ""
  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/http/preseed.pkrtpl", local.preseed)
  }
  boot_wait = "10s"
  boot_command = [
    "<wait><esc><wait>",
    "install <wait>",

    # TODO http://[http:port]/preseed.cfg cannot be reached
    " preseed/url=http://raw.githubusercontent.com/kencx/homelab/169608d8f84d5b53aa0dacbad7ece7f5ad995888/packer/vagrant/http/preseed.cfg <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "auto <wait>",
    "locale=en_US.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",

    # static network config
    "netcfg/disable_autoconfig=true <wait>",
    "netcfg/use_autoconfig=false <wait>",
    "netcfg/get_ipaddress=10.10.10.250 <wait>",
    "netcfg/get_netmask=255.255.255.0 <wait>",
    "netcfg/get_gateway=10.10.10.1 <wait>",
    "netcfg/get_nameservers=192.168.86.49 <wait>",
    "netcfg/confirm_static=true <wait>",
    "netcfg/get_hostname=${var.vm_name} <wait>",
    "netcfg/get_domain=base.com <wait>",

    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=default <wait>",
    "<enter><wait>",
  ]
}

build {
  sources = [
    "source.qemu.base",
    "source.proxmox-iso.base",
  ]

  # Make user ssh-ready for Ansible
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline = [
      "HOME_DIR=/home/${var.ssh_username}/.ssh",
      "mkdir -m 0700 -p $HOME_DIR",
      "echo '${local.ssh_public_key}' >> $HOME_DIR/authorized_keys",
      "chown -R ${var.ssh_username}:${var.ssh_username} $HOME_DIR",
      "chmod 0600 $HOME_DIR/authorized_keys",
      "SUDOERS_FILE=/etc/sudoers.d/${var.ssh_username}",
      "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > $SUDOERS_FILE",
      "chmod 0440 $SUDOERS_FILE",
    ]
    expect_disconnect = true
  }

  # common post-provisioning
  provisioner "ansible" {
    playbook_file = "../../ansible/common.yml"
    extra_arguments = [
      "-e",
      "user=${var.ssh_username}",
      "-e",
      "ansible_become_password=${var.ssh_password}",
    ]
    galaxy_file = "../../requirements.yml"
    user        = var.ssh_username
    ansible_env_vars = [
      "ANSIBLE_STDOUT_CALLBACK=yaml",
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
  }

  # vagrant-specific setup
  provisioner "shell" {
    only            = ["source.qemu.base"]
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts = [
      "./bin/vagrant.sh",
      "./bin/minimize.sh"
    ]
    expect_disconnect = true
  }

  post-processors {
    post-processor "vagrant" {
      only   = ["source.qemu.base"]
      output = "./builds/{{ .BuildName }}.{{ .Provider }}.${formatdate("YYYY-MM-DD", timestamp())}.box"
    }
  }
}
