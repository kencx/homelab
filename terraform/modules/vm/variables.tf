variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "hostname" {
  type        = string
  description = "Hostname of VM (defaults to test-vm)"
  default     = "test-vm"
}

variable "vmid" {
  type        = number
  description = "VM ID (defaults to 950)"
  default     = 950
}

variable "vm_template_name" {
  type        = string
  description = "VM Template Name"
  default     = "debian-cloudinit"
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

variable "bridge" {
  type        = string
  description = "VM network device"
  default     = "vmbr1"
}

variable "ip_address" {
  type        = string
  description = "VM IP address (mandatory)"
}

variable "gateway" {
  type        = string
  description = "VM Gateway (mandatory)"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key"
  default     = ""
}
