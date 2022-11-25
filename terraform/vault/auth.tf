resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
  tune {
    default_lease_ttl = "2h"
    max_lease_ttl     = "24h"
  }
}

# admin userpass for UI login
resource "vault_generic_endpoint" "admin" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true
  disable_read         = true
  disable_delete       = true

  data_json = <<EOF
{
  "password": "${var.admin_password}",
  "token_policies": ["admin"],
  "token_ttl": "2h",
  "token_max_ttl": "24h"
}
EOF
}

resource "vault_auth_backend" "cert" {
  type = "cert"
  path = "cert"
  tune {
    default_lease_ttl = "2h"
    max_lease_ttl     = "24h"
  }
}

resource "vault_pki_secret_backend_cert" "consul_template" {
  depends_on  = [vault_pki_secret_backend_role.auth_role]
  backend     = vault_mount.pki_int.path
  name        = vault_pki_secret_backend_role.auth_role.name
  common_name = "consul_template@global.vault"
  ttl         = "24h"
}

# TODO need to be pushed to server
resource "local_file" "consul_template_cert" {
  content         = vault_pki_secret_backend_cert.consul_template.certificate
  filename        = "${path.module}/certs/consul_template.crt"
  file_permission = "0640"
}

resource "local_sensitive_file" "consul_template_key" {
  content         = vault_pki_secret_backend_cert.consul_template.private_key
  filename        = "${path.module}/certs/consul_template.pem"
  file_permission = "0400"
}

resource "local_file" "consul_template_ca" {
  content         = vault_pki_secret_backend_cert.consul_template.issuing_ca
  filename        = "${path.module}/certs/consul_template_ca.crt"
  file_permission = "0640"
}

resource "vault_cert_auth_backend_role" "consul_template" {
  backend        = vault_auth_backend.cert.path
  name           = "consul_template"
  display_name   = "consul_template"
  certificate    = vault_pki_secret_backend_cert.consul_template.certificate
  token_ttl      = 86400
  token_period   = 86400
  token_policies = ["consul_template"]
}

data "vault_auth_backend" "token" {
  path = "token"
}

resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name              = "nomad_cluster"
  allowed_policies       = ["nomad_cluster"]
  allowed_entity_aliases = ["nomad_token"]
  token_period           = 259200 # 72h
  orphan                 = true
  renewable              = true
}

# identities, entities

resource "vault_identity_entity" "admin" {
  name     = "admin"
  policies = ["default", "admin"]
}

resource "vault_identity_entity_alias" "admin_userpass" {
  name           = "admin_userpass"
  canonical_id   = vault_identity_entity.admin.id
  mount_accessor = vault_auth_backend.userpass.accessor
}

resource "vault_identity_entity_alias" "admin_token" {
  name           = "admin_token"
  canonical_id   = vault_identity_entity.admin.id
  mount_accessor = data.vault_auth_backend.token.accessor
}

resource "vault_identity_entity" "consul_template" {
  name     = "consul_template"
  policies = ["default", "consul_template"]
}

resource "vault_identity_entity_alias" "consul_template_cert" {
  name           = "consul_template_cert"
  canonical_id   = vault_identity_entity.consul_template.id
  mount_accessor = vault_auth_backend.cert.accessor
}

resource "vault_identity_entity" "nomad" {
  name     = "nomad"
  policies = ["default", "nomad_cluster"]
}

resource "vault_identity_entity_alias" "nomad_token" {
  name           = "nomad_token"
  canonical_id   = vault_identity_entity.nomad.id
  mount_accessor = data.vault_auth_backend.token.accessor
}
