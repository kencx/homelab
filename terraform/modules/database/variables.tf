variable "postgres_vault_backend" {
  type        = string
  description = "Mount for Postgres database secrets engine."
  default     = "postgres"
}

variable "postgres_db_name" {
  type        = string
  description = "Unique name of Postgres database connection to use for static role."
  default     = "postgres"
}

variable "postgres_role_name" {
  type        = string
  description = "Postgres role name."
}

variable "postgres_role_password" {
  type        = string
  sensitive   = true
  description = "Temporary password for Postgres role. This will be rotated and managed by Vault."
}

variable "postgres_static_role_rotation_period" {
  type        = number
  description = "Postgres role password rotation period (in s)."
  default     = 86400
}
