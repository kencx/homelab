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
  default   = ""
  sensitive = true
}

variable "proxmox_api_token_id" {
  type      = string
  default   = ""
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  default   = ""
  sensitive = true
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
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment (mandatory)"
}

variable "vmid" {
  type        = number
  description = "VM ID (mandatory)"

  validation {
    condition     = var.vmid >= 100
    error_message = "VM ID must be >= 100."
  }
}

variable "lxc_template_name" {
  type        = string
  description = "LXC template (mandatory)"
}

variable "network_address" {
  type        = string
  description = "Network Address (mandatory)"
}

variable "subnet_mask" {
  type        = number
  description = "Subnet Mask (mandatory)"

  validation {
    condition     = var.subnet_mask <= 32 && var.subnet_mask > 0
    error_message = "Subnet mask must be between 0 and 32."
  }
}

variable "mounts" {
  type = list(object({
    key     = number
    slot    = string
    storage = string
    volume  = string
    mp      = string
    size    = string
  }))
  description = "LXC mount points (optional)"
  default     = []
}
