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
  default = "pve"
}

variable "iso_url" {
  type        = string
  description = "URL for ISO file"
}

variable "iso_checksum" {
  type        = string
  description = "Checksum for ISO file"
}

variable "vm_id" {
  type        = number
  default     = 9000
  description = "ID of temp VM during build process"
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
