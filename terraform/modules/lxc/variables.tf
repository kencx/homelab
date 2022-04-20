
variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "vm_id" {
  type        = number
  description = "LXC ID (defaults to 900)"
  default     = 900
}

variable "hostname" {
  type        = string
  description = "Name of container (defaults to test-lxc)"
  default     = "test-lxc"
}

variable "lxc_template" {
  type        = string
  description = "LXC template to deploy (mandatory)"
}

variable "unprivileged" {
  type        = bool
  description = "Start as unprivileged container"
  default     = true
}

variable "onboot" {
  type        = bool
  description = "Start container on boot"
  default     = false
}
variable "start" {
  type        = bool
  description = "Start on creation"
  default     = true
}

variable "cores" {
  type        = number
  description = "Number of cores"
  default     = 1
}

variable "memory" {
  type        = number
  description = "Memory in MB"
  default     = 1024
}

variable "swap" {
  type        = number
  description = "Swap space in MB"
  default     = 1024
}

variable "size" {
  type        = string
  description = "File system size"
  default     = "5G"
}

variable "proxmox_storage_pool" {
  type        = string
  description = ""
  default     = "volumes"
}

variable "mounts" {
  type        = list(any)
  description = "List of mounts (optional)"
  default     = []
}

variable "bridge" {
  type        = string
  description = "LXC network device"
  default     = "vmbr1"
}

variable "ip_address" {
  type        = string
  description = "LXC IP address (mandatory)"
}

variable "gateway" {
  type        = string
  description = "LXC Gateway (mandatory)"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key"
  default     = ""
}
