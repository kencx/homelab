variable "hcloud_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "ssh_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "cloud_config_path" {
  type        = string
  description = "Path to cloud-config file"
  default     = "./cloud-config"
}
