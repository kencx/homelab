variable "cloudflare_api_token" {
  description = "Cloudflare API token"
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
