
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

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "lxc_template_name" {
  type        = string
  description = "LXC template"
  default     = "debian-10-standard_10.7-1_amd64.tar.gz"
}

variable "apps_id" {
  type = number
}

variable "ip_block" {
  type        = string
  description = "IP address block"
}
