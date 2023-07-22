variable "hcloud_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
}

variable "vps_username" {
  type        = string
  description = "User to create"
}

variable "vps_password" {
  type        = string
  description = "Password for created user"
  sensitive   = true
}

variable "vps_timezone" {
  type        = string
  description = "System timezone"
  default     = "Asia/Singapore"
}

variable "vps_packages" {
  type        = list(any)
  description = "List of packages to install"
  default     = ["git", "curl", "sudo"]
}
