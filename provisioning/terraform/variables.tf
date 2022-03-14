
variable "proxmox_ip" {
	type        = string
	description = "IP of Proxmox server"
}

variable "proxmox_api_token_id" {
	type = string
}

variable "proxmox_api_token_secret" {
	type = string
}

variable "target_node" {
	type = string
	default = "pve"
}

variable "proxmox_storage_pool" {
	type = string
	default = "volumes"
}

