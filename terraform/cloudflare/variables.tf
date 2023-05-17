variable "cloudflare_email" {
  description = "Cloudflare Email"
  type        = string
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  sensitive   = true
}

variable "blog_url" {
  description = "DNS A record for blog"
  type        = string
}

variable "vps_ip_address" {
  description = "IP Address of VPS host"
  type        = string
}
