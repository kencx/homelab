# Adding a New Application

Some notes when adding a new application jobspec to Nomad in
`terraform/nomad/apps`.

## Traefik

To place the application behind the Traefik reverse proxy, its jobspec should
include the `service.tags`:

```hcl
tags = [
    "traefik.enable=true",
    "traefik.http.routers.app-proxy.entrypoints=https",
    "traefik.http.routers.app-proxy.tls=true",
    "traefik.http.routers.app-proxy.rule=Host(`app.example.tld`)",
]
```

## Secrets

This section is relevant if the application requires KV secrets from Vault. It
uses the [Vault Terraform module](../terraform/vault.md).

1. Firstly, add the relevant KV secrets to Vault.

2. Next, create and add a Vault policy for read-only access to the relevant KV secrets:

```hcl
# terraform/vault/policies/nomad_app.hcl
path "kvv2/data/prod/nomad/app" {
    capabilities = ["read"]
}

# terraform/vault/policies.tf
resource "vault_policy" "nomad_app" {
    name   = "nomad_app"
    policy = file("policies/nomad_app.hcl")
}
```


3. Include the `vault` and `template` blocks in the Nomad jobspec:

```hcl
vault {
    policies = ["nomad_app"]
}

template {
    data        = <<EOF
{{ with secret "kvv2/data/prod/nomad/app" }}
AUTH="{{ .Data.data.username }}":"{{ .Data.data.password }}"
{{ end }}
EOF
    destination = "secrets/auth.env"
    env         = true
}
```

This will access the Vault secrets and include them as the `AUTH` environment
variable in the job.

## Database

This section is relevant if the application requires access to the Postgres
database. It uses the [Postgres Terraform module](../terraform/postgres.md).

1. Add the application name into the `postgres_roles` variable in
`terraform/postgres/`:

```hcl
postgres_roles = [
    {
        name = "app"
        rotation_period = 86400
    }
]
```

This will create a Postgres role and database in the running Postgres
instance, a static role in Vault for rotation of the role's credentials, and
a Vault policy to read the role's credentials.

2. Add a `template` and `vault` block to access the database credentials:

```hcl
vault {
    policies = ["app"]
}

template {
    data        = <<EOF
{{ with secret "postgres/static-creds/app" }}
DATABASE_URL = "postgres://foo:{{ .Data.password }}@localhost:5432/foo?sslmode=disable"
{{ end }}
EOF
    destination = "secrets/.env"
    env         = true
}
```
