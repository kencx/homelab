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

provider "vault" {
  address      = var.vault_address
  token        = var.vault_token
  ca_cert_file = var.vault_ca_cert_file
}

provider "postgresql" {
  host     = var.postgres_host
  port     = var.postgres_port
  database = var.postgres_database
  username = var.postgres_username
  password = var.postgres_password
  sslmode  = "disable"
}

locals {
  connection_url = "postgres://${var.postgres_username}:${var.postgres_password}@${var.postgres_host}:${var.postgres_port}/${var.postgres_database}"

  roles = {
    for role in var.postgres_roles : role.name => role.rotation_period
  }
}

resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgres"
  allowed_roles = ["*"]

  postgresql {
    connection_url = local.connection_url
  }
}

# NOTE: Remember to add the created policy to
# vault_token_auth_backend_role.nomad_cluster
module "role" {
  source   = "../modules/database"
  for_each = local.roles

  postgres_vault_backend = vault_mount.db.path
  postgres_db_name       = vault_database_secret_backend_connection.postgres.name

  postgres_role_name                   = each.key
  postgres_role_password               = each.key
  postgres_static_role_rotation_period = each.value
}
