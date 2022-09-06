variable "proxmox_ip" {
  type        = string
  description = "IP of Proxmox server (mandatory)"
}

variable "proxmox_user" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "hostname" {
  type        = string
  description = "Hostname of VM (defaults to base)"
  default     = "base"
}

variable "vmid" {
  type        = number
  description = "VM ID (defaults to 400)"
  default     = 400
}

variable "template_name" {
  type        = string
  description = "Template to clone"
}

variable "onboot" {
  type        = bool
  description = "Start VM on boot"
  default     = false
}

variable "oncreate" {
  type        = bool
  description = "Start VM on creation"
  default     = true
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

variable "ssh_user" {
  type        = string
  description = "SSH user"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Private SSH key file"
}

variable "ssh_public_key_file" {
  type        = string
  description = "Public SSH key file"
}
