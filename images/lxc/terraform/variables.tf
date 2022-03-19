
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

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID"
  default     = 900
}

variable "base_template" {
  type        = string
  description = "Base LXC template"
  default     = "local:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz"
}

variable "size" {
  type        = string
  description = "Storage disk size"
  default     = "5G"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "volumes"
}

variable "ip_address" {
  type        = string
  description = "IP address of LXC"
}

variable "gateway" {
  type        = string
  description = "Gateway address of LXC"
}

variable "ssh_user" {
  type = string
}
