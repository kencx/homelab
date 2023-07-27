variable "vault_address" {
  type        = string
  description = "Vault address"
  default     = "https://localhost:8200"
}

variable "vault_token" {
  type        = string
  sensitive   = true
  description = "Vault token for provider"
}

variable "vault_ca_cert_file" {
  type        = string
  description = "Local path to Vault CA cert file"
  default     = "../../certs/vault-ca.crt"
}

variable "postgres_username" {
  type        = string
  description = "Postgres root username"
  default     = "postgres"
}

variable "postgres_password" {
  type        = string
  sensitive   = true
  description = "Postgres root password"
  default     = "postgres"
}

variable "postgres_database" {
  type        = string
  description = "Postgres database"
  default     = "postgres"
}

variable "postgres_host" {
  type        = string
  description = "Postgres host"
  default     = "localhost"
}

variable "postgres_port" {
  type        = string
  description = "Postgres port"
  default     = "5432"
}

variable "postgres_roles" {
  type = list(object({
    name            = string
    rotation_period = optional(number, 86400)
  }))
  description = "List of roles with name and rotation period in sec (default 86400s)."
  validation {
    condition     = alltrue([for r in var.postgres_roles : r.rotation_period > 0])
    error_message = "Rotation period cannot be <= 0"
  }
}
