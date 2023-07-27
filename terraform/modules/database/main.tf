terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.18.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.19.0"
    }
  }
}

resource "postgresql_role" "role" {
  name            = var.postgres_role_name
  password        = var.postgres_role_password
  login           = true
  create_database = true
}

resource "postgresql_database" "database" {
  name       = var.postgres_role_name
  owner      = var.postgres_role_name
  depends_on = [postgresql_role.role]
}

resource "vault_database_secret_backend_static_role" "static_role" {
  backend  = var.postgres_vault_backend
  name     = var.postgres_role_name
  username = var.postgres_role_name
  db_name  = var.postgres_db_name

  rotation_period = var.postgres_static_role_rotation_period
  rotation_statements = [
    "ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"
  ]
  depends_on = [postgresql_database.database]
}

locals {
  policy_path = "${var.postgres_vault_backend}/static-creds/${var.postgres_role_name}"
}

data "vault_policy_document" "policy_document" {
  rule {
    path         = local.policy_path
    capabilities = ["read"]
  }
}

resource "vault_policy" "policy" {
  name   = var.postgres_role_name
  policy = data.vault_policy_document.policy_document.hcl
}
