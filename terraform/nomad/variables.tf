variable "nomad_address" {
  type        = string
  description = "Nomad server address"
  default     = "http://localhost:4646"
}

variable "proxmox_address" {
  type        = string
  description = <<EOF
  The full IP address for a Proxmox instance, with scheme and port.

  Format: https://192.1.0.2:8006
EOF
}

variable "datacenters" {
  type        = list(string)
  description = "The datacenters to run jobs."
  default     = ["dc1"]
}

variable "domain" {
  type        = string
  description = "The common domain name for all applications."
}

variable "timezone" {
  type        = string
  description = "The timezone for all applications."
  default     = "Asia/Singapore"
}

variable "traefik_image_version" {
  type        = string
  description = "Docker image version for Traefik"
}

variable "traefik_volumes_acme" {
  type        = string
  description = "Acme volume for Traefik"
}

variable "traefik_volumes_logs" {
  type        = string
  description = "Logs volume for Traefik"
}

variable "traefik_consul_provider_address" {
  type        = string
  description = "Consul server address for Traefik"
}

variable "traefik_acme_ca_server" {
  type        = string
  description = "The ACME CA server for Traefik certificate resolver"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "yarr_image_version" {
  type        = string
  description = "Docker image version for yarr"
}

variable "yarr_volumes_data" {
  type        = string
  description = "Data volume for yarr"
}

variable "minio_image_version" {
  type        = string
  description = "Docker image version for minio"
}

variable "minio_volumes_data" {
  type        = string
  description = "Data volume for minio"
}

variable "actual_image_version" {
  type        = string
  description = "Docker image version for actual"
}

variable "actual_volumes_server" {
  type        = string
  description = "Server volume for actual"
}

variable "actual_volumes_user" {
  type        = string
  description = "User volume for actual"
}

variable "linkding_image_version" {
  type        = string
  description = "Docker image version for linkding"
}

variable "linkding_volumes_data" {
  type        = string
  description = "Data volume for linkding"
}

variable "diun_image_version" {
  type        = string
  description = "Docker image version for diun"
}

variable "diun_volumes_data" {
  type        = string
  description = "Data volume for diun"
}

variable "diun_watch_schedule" {
  type        = string
  description = "Crontab for diun watch schedule"
  default     = "0 0 * * 5"
}

variable "openbooks_image_version" {
  type        = string
  description = "Docker image version for openbooks"
}

variable "openbooks_volumes_books" {
  type        = string
  description = "Books volume for openbooks"
}

variable "calibre_web_image_version" {
  type        = string
  description = "Docker image version for calibre web"
}

variable "calibre_web_volumes_config" {
  type        = string
  description = "Config volume for calibre web"
}

variable "calibre_web_volumes_books" {
  type        = string
  description = "Books volume for calibre web"
}

variable "paperless_image_version" {
  type        = string
  description = "Docker image version for paperless-ngx"
}

variable "paperless_volumes_data" {
  type        = string
  description = "Data volume for paperless-ngx"
}

variable "paperless_volumes_consume" {
  type        = string
  description = "Consume volume for paperless-ngx"
}

variable "paperless_volumes_media" {
  type        = string
  description = "Media volume for paperless-ngx"
}

variable "postgres_image_version" {
  type        = string
  description = "Docker image version for postgres"
}

variable "postgres_volumes_data" {
  type        = string
  description = "Data volume for postgres"
}

variable "registry_image_version" {
  type        = string
  description = "Docker image version for registry"
}

variable "registry_volumes_data" {
  type        = string
  description = "Data volume for registry"
}
