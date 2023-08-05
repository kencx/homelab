# Vault

This uses the
[Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
provider to declaratively manage secrets and policies in a running Vault
instance. The Vault provider must be configured appropriately:

```tf
provider "vault" {
  address      = var.vault_address
  token        = var.vault_token
  ca_cert_file = var.vault_ca_cert_file
}
```

## Workspaces

Ansible initializes Vault in the [vault role](../roles/vault.md#initialization).
When doing so, any existing Vault resources in the same workspace are
**destroyed permanently**. As such, care should be taken to ensure the
appropriate workspaces are used when running the role on multiple Vault server
instances or environments (eg. dev and prod).

## Outputs

Vault produces the following outputs:

- Certificate key pair for Ansible certificate authentication to Vault

## Variables

| Variable             | Description                          | Type   | Default    |
| -------------------- | ------------------------------------ | ------ | ---------- |
| vault_address        | Vault address | string | `https://localhost:8200`          |
| vault_token        | (Root) Vault token for provider  | string |                  |
| vault_ca_cert_file | Local path to Vault CA cert file | string | `./certs/vault_ca.crt` |
| vault_audit_path   | Vault audit file path            | string | `/vault/logs/vault.log`|
| admin_password     | Password for admin user          | string | |
| kvuser_password | Password for kv user | string |
| allowed_server_domains | List of allowed_domains for PKI server role | list(string) | `["service.consul", "dc1.consul", "dc1.nomad", "global.nomad"]`|
| allowed_client_domains | List of allowed_domains for PKI client role | list(string) | `["service.consul", "dc1.consul", "dc1.nomad", "global.nomad"]` |
| allowed_auth_domains   | List of allowed_domains for PKI auth role | list(string) | `["global.vault"]`|
| allowed_vault_domains  | List of allowed_domains for PKI vault role | list(string) | `["vault.service.consul", "global.vault"]`|
| ansible_public_key_path | Local path to store Ansible public key for auth | string | `../../certs/ansible.crt` |
| ansible_private_key_path | Local path to store Ansible private key for auth | string | `../../certs/ansible_key.pem` |

## Notes

- The resources for Postgres database secrets engine are configured separately
  in [Postgres](./postgres.md). This is because the Postgres database might not
  be up when Vault is being initialized.
- It is not recommended to change the `ansible_*_key_path` variables. Changing
  them will heavily affect the Ansible roles when they attempt to login to Vault
  with the auth certs.
