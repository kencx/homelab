
terraform {
	required_providers {
		proxmox = {
			source = "telmate/proxmox"
			version = "2.9.6"
		}
	}
}

locals {
	proxmox_api_url = "https://${var.proxmox_ip}:8006/api2/json"
}

provider "proxmox" {
	pm_api_url		= local.proxmox_api_url
	pm_tls_insecure = true

	pm_api_token_id     = var.proxmox_api_token_id
	pm_api_token_secret = var.proxmox_api_token_secret
}

module "test_container" {
	source = "./modules/lxc"

	target_node = "pve"
	vm_id = 115
	hostname = "staging"
	lxc_template = "local:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz"
	unprivileged = true
	onboot = true
	start = true

	cores = 2
	memory = 4096
	swap = 2048

	size = "5G"
	proxmox_storage_pool = "volumes"

	ip_address = "10.10.10.100/24"
	sshkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIc7rqDR7KB1TWIOWbaL7yG8//ujgkGCq7L7lt1CsIJia50+gcB4yTFUcJuJPJYu7pLJarKaMMQlzSPl6Mn+doA93JN7dDQ/L5bDfhDny0j7L2+56i3AXINV4sibeyHwXD38Nn5cr/2q7d/5xWjuHGxHhJU5urcEn4I4o3AQyMKsmTY/C6BzUbkxe3jQECFiKyRxUh6Byi/rMSq7w4Gy0kXfcgD8/C5BKBdyMzCP+Ln2L/ywCdXGo2wWU0JpVsfZpY0aZ7B4oqLKqgw+XgUQBaLLpzBwXKV+rrZB9ikBjbUyD7u11kwxkFOb5fLPWjwyJ5sSm/WQjHs87dvH2AinMN root@pve"
}

