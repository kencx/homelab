data "vault_policy_document" "update_userpass" {
  rule {
    path         = "auth/userpass/users/{{ identity.entity.aliases.${vault_auth_backend.userpass.accessor}.name }}"
    capabilities = ["update"]
    allowed_parameter {
      key   = "password"
      value = []
    }
  }
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin.hcl")
}

resource "vault_policy" "update_userpass" {
  name   = "update_userpass"
  policy = data.vault_policy_document.update_userpass.hcl
}

resource "vault_policy" "consul_template" {
  name   = "consul_template"
  policy = file("policies/consul_template.hcl")
}

resource "vault_policy" "nomad_startup" {
  name   = "nomad_startup"
  policy = file("policies/nomad_startup.hcl")
}

resource "vault_policy" "nomad_cluster" {
  name   = "nomad_cluster"
  policy = file("policies/nomad_token.hcl")
}

resource "vault_policy" "ansible" {
  name   = "ansible"
  policy = file("policies/ansible.hcl")
}

resource "vault_policy" "kvuser" {
  name   = "kvuser"
  policy = file("policies/kvuser.hcl")
}

resource "vault_policy" "nomad_yarr" {
  name   = "nomad_yarr"
  policy = file("policies/nomad_yarr.hcl")
}

resource "vault_policy" "nomad_linkding" {
  name   = "nomad_linkding"
  policy = file("policies/nomad_linkding.hcl")
}

resource "vault_policy" "nomad_traefik" {
  name   = "nomad_traefik"
  policy = file("policies/nomad_traefik.hcl")
}
