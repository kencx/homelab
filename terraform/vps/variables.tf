variable "vps_hcloud_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "vps_ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "vps_ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
}

variable "vps_username" {
  type        = string
  description = "Username of VPS user"
}

variable "vps_password" {
  type        = string
  description = "Password of VPS user"
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

variable "vps_certbot_email" {
  type        = string
  description = "Admin email for certbot"
  sensitive   = true
}
