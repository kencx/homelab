source "qemu" "base" {
  vm_name          = var.vm_name
  headless         = true
  shutdown_command = "echo '${var.ssh_username}' | sudo -S /sbin/shutdown -hP now"

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

  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_port         = 22
  ssh_wait_timeout = "3600s"

  http_directory = "${path.root}/http"
  boot_wait      = "5s"
  boot_command   = ["<esc><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><enter><wait>"]
}

build {
  sources = ["source.qemu.base"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_username}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts = [
      "./bin/vagrant.sh",
      "./bin/networking.sh",
      "./bin/minimize.sh"
    ]
    expect_disconnect = true
  }

  post-processors {
    post-processor "vagrant" {
      output = "./builds/{{ .BuildName }}.{{ .Provider }}.{{ timestamp }}.box"
    }
  }
}
