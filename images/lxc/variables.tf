
variable "proxmox_ip" {
  type        = string
  description = "IP of Proxmox server"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID for TERRAFORM"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret for TERRAFORM"
  sensitive   = true
}

variable "proxmox_api_token_id_ansible" {
  type        = string
  description = "Proxmox API token ID for ANSIBLE"
  sensitive   = true
}

variable "proxmox_api_token_secret_ansible" {
  type        = string
  description = "Proxmox API token secret for ANSIBLE"
  sensitive   = true
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
}

variable "template_name" {
  type        = string
  description = "Base LXC template name"
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

variable "subnet_mask" {
  type        = string
  description = "Subnet Mask of LXC"
  default     = "/24"
}

variable "gateway" {
  type        = string
  description = "Gateway address of LXC"
}

variable "ansible_inventory_path" {
  type        = string
  description = "Path to Ansible hosts file"
  default     = "../playbooks/inventory/hosts.yml"
}
