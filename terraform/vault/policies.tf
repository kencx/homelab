resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin.hcl")
}

resource "vault_policy" "consul_template" {
  name   = "consul_template"
  policy = file("policies/consul_template.hcl")
}

resource "vault_policy" "nomad_cluster" {
  name   = "nomad_cluster"
  policy = file("policies/nomad_token.hcl")
}

resource "vault_policy" "ansible" {
  name   = "ansible"
  policy = file("policies/ansible.hcl")
}

resource "vault_policy" "nomad_yarr" {
  name   = "nomad_yarr"
  policy = file("policies/nomad_yarr.hcl")
}
