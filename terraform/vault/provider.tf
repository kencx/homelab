terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.11.0"
    }
  }
}

# TODO replace token and ca_file
provider "vault" {
  address      = var.vault_address
  token        = var.vault_token
  ca_cert_file = "./certs/vault_ca.crt"
}
