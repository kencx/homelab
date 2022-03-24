
variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "vm_id" {
  type        = number
  description = "LXC ID"
  default     = 900
}

variable "hostname" {
  type        = string
  description = "Name of container"
  default     = "test-lxc"
}

variable "lxc_template" {
  type        = string
  description = "LXC template to deploy"
  default     = "local:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz"
}

variable "unprivileged" {
  type        = bool
  description = "Unprivileged container"
  default     = true
}

variable "onboot" {
  type        = bool
  description = "Start container on boot"
  default     = true
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
  description = "Memory"
  default     = 1024
}

variable "swap" {
  type        = number
  description = "Swap"
  default     = 2048
}

variable "size" {
  type        = string
  description = "File system size"
  default     = "5G"
}

variable "proxmox_storage_pool" {
  type        = string
  description = ""
  default     = "local-lvm"
}

variable "bridge" {
  type = string
  description = "LXC network device"
  default = "vmbr1"
}

variable "ip_address" {
  type        = string
  description = "LXC IP address"
}

variable "gateway" {
  type        = string
  description = "LXC Gateway"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key"
}
