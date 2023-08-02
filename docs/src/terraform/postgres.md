# Postgres

This uses the
[Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs) and
[Postgresql](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs)
provider to declaratively manage roles and databases in a single Postgres
instance.

The Vault and Postgres provider must be configured appropriately:

```hcl
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
```

## Overview

This Terraform configuration provisions and manages multiple databases a single
instance of Postgres. It uses a custom module (`terraform/modules/database`) to
create a new role and database for a given application. Vault is then used to
periodically rotate the database credentials with a [static role in the database
secrets
engine](https://developer.hashicorp.com/vault/docs/secrets/databases#static-roles).
To access the rotated credentials in Vault from Nomad, a relevant Vault policy
is also created.

## Prerequisites

- An existing Vault instance
- To access the credentials in Nomad, Vault integration must be configured
- An existing Postgres instance

Minimally, the Postgres instance should have a default user and database
(`postgres`) that can has the privileges to create roles and databases. The
connection credentials must be passed as variables.

## Usage

The `database` module requires two shared resources from Vault:

```hcl
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
```

These resources provide a single shared backend and DB connection that must be passed
to each module:

```hcl
module "role" {
  source   = "../modules/database"
  for_each = local.roles

  postgres_vault_backend = vault_mount.db.path
  postgres_db_name       = vault_database_secret_backend_connection.postgres.name

  postgres_role_name                   = each.key
  postgres_role_password               = each.key
  postgres_static_role_rotation_period = each.value
}
```

The `for_each` meta-argument simplifies the use of the module further by simply
requiring a list of role objects as input:

```hcl
postgres_roles = [
  {
    name = "foo"
    rotation_period = 86400
  },
  {
    name = "bar"
  },
]
```

- `name` is the chosen name of the role
- `rotation_period` is the password rotation period of the role in seconds
  (optional with a default of `86400`)

The Nomad job obtains the database credentials with a `template` and `vault` block:

```hcl
vault {
  policies = ["foo"]
}

template {
  data        = <<EOF
{{ with secret "postgres/static-creds/foo" }}
DATABASE_URL = "postgres://foo:{{ .Data.password }}@localhost:5432/foo?sslmode=disable"
{{ end }}
EOF
  destination = "secrets/.env"
  env         = true
}
```

## Variables

| Variable             | Description                          | Type   | Default    |
| -------------------- | ------------------------------------ | ------ | ---------- |
| vault_address        | Vault address | string | `https://localhost:8200`          |
| vault_token        | (Root) Vault token for provider  | string |                  |
| vault_ca_cert_file | Local path to Vault CA cert file | string | `./certs/vault_ca.crt` |
| postgres_username | Postgres root username | string | `postgres` |
| postgres_password | Postgres root password | string | `postgres` |
| postgres_database | Postgres database | string | `postgres` |
| postgres_host | Postgres host | string | `localhost`
| postgres_port | Postgres port | string | `"5432"` |
| postgres_roles | List of roles to be added | list(object) | |

## Notes

- Any new entries must also be added to `allowed_policies` in the
  `vault_token_auth_backend_role.nomad_cluster` resource in [Vault](./vault.md)
  to be available by Nomad.
