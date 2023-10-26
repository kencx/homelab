variable "proxmox_ip" {
  type        = string
  description = "IP of Proxmox server (mandatory)"
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "tags" {
  type        = list(string)
  description = "VM tags"
  default     = ["prod"]
}

variable "template_id" {
  type        = number
  description = "Template ID to clone"
}

variable "onboot" {
  type        = bool
  description = "Start VM on boot"
  default     = false
}

variable "started" {
  type        = bool
  description = "Start VM on creation"
  default     = true
}

variable "server_hostname_prefix" {
  type        = string
  description = "Hostname prefix of server node"
  default     = "server"
}

variable "client_hostname_prefix" {
  type        = string
  description = "Hostname prefix of client node"
  default     = "client"
}

variable "server_vmid" {
  type        = list(number)
  description = "List of server VM IDs"
}

variable "client_vmid" {
  type        = list(number)
  description = "List of client VM IDs"
}

variable "server_cores" {
  type        = number
  description = "Number of cores in server nodes"
  default     = 2
}

variable "server_sockets" {
  type        = number
  description = "Number of sockets in server nodes"
  default     = 2
}

variable "server_memory" {
  type        = number
  description = "Memory (MB) in server nodes"
  default     = 2048
}

variable "server_disk_size" {
  type        = number
  description = "Disk size (GB) in server nodes"
  default     = 5
}

variable "client_cores" {
  type        = number
  description = "Number of cores in client nodes"
  default     = 2
}

variable "client_sockets" {
  type        = number
  description = "Number of sockets in client nodes"
  default     = 2
}

variable "client_memory" {
  type        = number
  description = "Memory (MB) in client nodes"
  default     = 1024
}

variable "client_disk_size" {
  type        = number
  description = "Disk size (GB) in server nodes"
  default     = 5
}

variable "disk_datastore" {
  type        = string
  description = "Datastore on which to store disk"
  default     = "volumes"
}

variable "server_ip_address" {
  type        = list(string)
  description = "List of server IPv4 address in CIDR notation (eg. 10.10.10.2/24)"
  validation {
    condition = alltrue([
      for i in var.server_ip_address : can(cidrnetmask(i))
    ])
    error_message = "Must be a valid IPv4 address with subnet mask"
  }
}

variable "client_ip_address" {
  type        = list(string)
  description = "List of client IPv4 address in CIDR notation (eg. 10.10.10.2/24)"
  validation {
    condition = alltrue([
      for i in var.client_ip_address : can(cidrnetmask(i))
    ])
    error_message = "Must be a valid IPv4 address with subnet mask"
  }
}

variable "control_ip_address" {
  type        = string
  description = "Control IPv4 address in CIDR notation (eg. 10.10.10.2/24)"
  validation {
    condition     = can(cidrnetmask(var.control_ip_address))
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

variable "ssh_public_key_file" {
  type        = string
  description = "Public SSH key file"
}
