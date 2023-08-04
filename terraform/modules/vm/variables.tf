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

variable "tags" {
  type        = string
  description = "VM tags"
  default     = ""
}

variable "description" {
  type        = string
  description = "VM description"
  default     = "This VM is managed by Terraform."
}

variable "clone_template_name" {
  type        = string
  description = "VM Template name to clone"
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

variable "disk_size" {
  type        = string
  description = <<EOT
  (Optional) VM bootdisk size

  Default: 10G
  EOT
  default     = "10G"
}

variable "disk_storage_pool" {
  type        = string
  description = "Storage pool on which to store disk"
  default     = "volumes"
}

variable "ip_address" {
  type        = string
  description = "VM IPv4 address in CIDR notation (eg. 10.10.10.2/24)"
  validation {
    condition     = can(cidrnetmask(var.ip_address))
    error_message = "Must be a valid IPv4 address with subnet mask"
  }
}

variable "ip_gateway" {
  type        = string
  description = "IP gateway address (eg. 10.10.10.1)"
  validation {
    condition     = can(cidrnetmask("${var.ip_gateway}/24"))
    error_message = "Must be a valid IPv4 address"
  }
}

variable "ssh_user" {
  type        = string
  description = "SSH user"
}

variable "ssh_private_key" {
  type        = string
  description = "Private SSH key"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key"
}
