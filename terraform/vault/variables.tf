variable "vault_address" {
  type        = string
  description = "Vault address"
  default     = "https://localhost:8200"
}

variable "vault_token" {
  type        = string
  sensitive   = true
  description = "Vault token for provider"
}

variable "vault_ca_cert_file" {
  type        = string
  description = "Local path to Vault CA cert file"
  default     = "../../certs/vault-ca.crt"
}

variable "vault_audit_path" {
  type        = string
  description = "Vault audit file path"
  default     = "/opt/vault/logs/vault.log"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password"
}

variable "kvuser_password" {
  type        = string
  sensitive   = true
  description = "kvuser password"
}

variable "allowed_server_domains" {
  type        = list(string)
  description = "List of allowed_domains for PKI server role"
  default     = ["service.consul", "dc1.consul", "dc1.nomad", "global.nomad"]
}

variable "allowed_client_domains" {
  type        = list(string)
  description = "List of allowed_domains for PKI client role"
  default     = ["service.consul", "dc1.consul", "dc1.nomad", "global.nomad"]
}

variable "allowed_auth_domains" {
  type        = list(string)
  description = "List of allowed_domains for PKI auth role"
  default     = ["global.vault"]
}

variable "allowed_vault_domains" {
  type        = list(string)
  description = "List of allowed_domains for PKI vault role"
  default     = ["vault.service.consul", "global.vault"]
}

# Changing these will affect the Ansible roles when they attempt to login to Vault with
# Ansible
variable "ansible_public_key_path" {
  type        = string
  description = "Local path to store Ansible public key for authentication"
  default     = "../../certs/ansible.crt"
}

variable "ansible_private_key_path" {
  type        = string
  description = "Local path to store Ansible private key for authentication"
  default     = "../../certs/ansible_key.pem"
}
