
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
  type    = string
  default = "pve"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "volumes"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key to root"
}

variable "staging_id" {
  type = number
}

variable "staging_user" {
  type = string
}

variable "cicd_id" {
  type = number
}

variable "cicd_user" {
  type = string
}

variable "ip_block" {
  type        = string
  description = "IP address block"
}
