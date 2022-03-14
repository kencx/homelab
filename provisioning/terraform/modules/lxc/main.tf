
terraform {
	required_providers {
		proxmox = {
			source = "telmate/proxmox"
			version = "2.9.6"
		}
	}
}

resource "proxmox_lxc" "lxc" {
	target_node = var.target_node
	vmid = var.vm_id
	hostname = var.hostname

	ostemplate = var.lxc_template
	unprivileged = var.unprivileged
	onboot = var.onboot
	start = var.start

	password = random_password.password.result

	cores = var.cores
	memory = var.memory
	swap = var.swap

	features {
		nesting = true
	}

	# mandatory
	rootfs {
		storage = var.proxmox_storage_pool
		size = var.size
	}

	network {
		name = "eth0"
		bridge = "vmbr0"
		ip = var.ip_address
	}

	ssh_public_keys = <<EOF
	${var.sshkey}
	EOF

	# run provisioner remote_exec and local_exec
}

resource "random_password" "password" {
	length = 20
	special = true
}
