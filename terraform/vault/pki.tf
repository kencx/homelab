resource "vault_mount" "pki" {
  path                  = "pki"
  type                  = "pki"
  description           = "Root PKI"
  max_lease_ttl_seconds = 315360000 # 10 years
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
  crl_distribution_points = [
    "http://127.0.0.1:8200/v1/pki/crl",
  ]
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on  = [vault_mount.pki]
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Vault PKI Root CA"
  ttl         = "87600h"
}

resource "vault_mount" "pki_int" {
  path                  = "pki_int"
  type                  = vault_mount.pki.type
  description           = "Intermediate PKI"
  max_lease_ttl_seconds = 315360000
}

# intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on  = [vault_mount.pki, vault_mount.pki_int]
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "Vault PKI Intermediate CA"
}

# intermediate cert
resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  depends_on  = [vault_pki_secret_backend_intermediate_cert_request.intermediate]
  backend     = vault_mount.pki.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = "Intermediate CA"
  ttl         = "43800h"
}

# import intermediate cert to Vault
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root.certificate
}
