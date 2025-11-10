variable "proxmox_url" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve01"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_bridge" {
  type    = string
  default = "vmbr0"
}

variable "clone_vm" {
  type        = string
  description = "Name of existing VM template to clone"
}

variable "vm_id" {
  type        = number
  description = "ID of VM template"
  default     = 5000
}

variable "vm_name" {
  type        = string
  description = "Name of VM template"
}

variable "template_description" {
  type        = string
  description = "Description of VM template"
  default     = "Debian 12 base image"
}

variable "cores" {
  type        = number
  description = "Number of cores"
  default     = 1
}

variable "sockets" {
  type        = number
  description = "Number of sockets"
  default     = 1
}

variable "memory" {
  type        = number
  description = "Memory in MB"
  default     = 1024
}

variable "ssh_username" {
  type = string
}

variable "ip_address" {
  type        = string
  description = "Temporary IP address of VM template"
  default     = "10.10.10.250"
}

variable "gateway" {
  type        = string
  description = "Gateway of VM template"
  default     = "10.10.10.1"
}

variable "ssh_public_key_path" {
  type        = string
  description = "SSH Public Key Path"
}

variable "ssh_private_key_path" {
  type        = string
  description = "SSH Private Key Path"
}
