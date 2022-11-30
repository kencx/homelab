resource "vault_pki_secret_backend_role" "server_role" {
  backend        = vault_mount.pki_int.path
  name           = "server"
  ttl            = "86400"
  max_ttl        = "259200"
  generate_lease = true

  allowed_domains    = concat(["localhost"], var.allowed_server_domains)
  allow_any_name     = false
  allow_glob_domains = true
  allow_subdomains   = true
  enforce_hostnames  = true

  client_flag = false
  server_flag = true
}

resource "vault_pki_secret_backend_role" "client_role" {
  backend        = vault_mount.pki_int.path
  name           = "client"
  ttl            = "86400"
  max_ttl        = "259200"
  generate_lease = true

  allowed_domains    = concat(["localhost"], var.allowed_client_domains)
  allow_any_name     = false
  allow_bare_domains = true # Required for email addresses
  allow_glob_domains = false
  allow_ip_sans      = true
  allow_subdomains   = true
  enforce_hostnames  = true

  client_flag = true
  server_flag = false
}

# issue auth certificates for username@global.vault
resource "vault_pki_secret_backend_role" "auth_role" {
  backend        = vault_mount.pki_int.path
  name           = "auth"
  ttl            = "86400"
  max_ttl        = "259200"
  generate_lease = true

  allowed_domains    = concat(["localhost"], var.allowed_auth_domains)
  allow_any_name     = false
  allow_bare_domains = true
  allow_glob_domains = false
  allow_ip_sans      = true
  allow_subdomains   = false
  enforce_hostnames  = true
}

resource "vault_pki_secret_backend_role" "vault_server" {
  backend        = vault_mount.pki_int.path
  name           = "vault"
  ttl            = "31536000"  # 1 year
  max_ttl        = "157788000" # 5 years
  generate_lease = true

  allowed_domains    = concat(["localhost"], var.allowed_vault_domains)
  allow_any_name     = false
  allow_bare_domains = true
  allow_glob_domains = true
  allow_ip_sans      = true
  allow_subdomains   = true
  enforce_hostnames  = true

  client_flag = false
  server_flag = true
}
