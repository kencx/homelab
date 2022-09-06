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

variable "clone_vm" {
  type        = string
  description = "Name of VM to clone"
}

variable "vm_id" {
  type        = number
  default     = 900
  description = "ID of temp VM during build process"
}

/* variable "template_name" { */
/*   type        = string */
/*   default     = "packer-template" */
/*   description = "Name of template after build process" */
/* } */
/**/
/* variable "template_description" { */
/*   type        = string */
/*   default     = "Template from cloud image" */
/*   description = "Description of template after build process" */
/* } */

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
