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
