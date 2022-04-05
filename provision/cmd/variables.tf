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

variable "cmd_id" {
  type = number
}

variable "cmd_user" {
  type        = string
  description = "cmd User"
  default     = "debian"
}

variable "cmd_drone_id" {
  type = number
}

variable "cmd_drone_user" {
  type        = string
  description = "cmd-drone User"
  default     = "debian"
}

variable "lxc_template_name" {
  type        = string
  description = "LXC template"
  default     = "debian-10-standard_10.7-1_amd64.tar.gz"
}

variable "ip_address" {
  type        = string
  description = "IP address"
}

variable "subnet_mask" {
  type        = string
  description = "Subnet Mask"
}

variable "github_access_token" {
  type        = string
  description = "Github Personal Access Token for Ansible play git_ssh"
}
