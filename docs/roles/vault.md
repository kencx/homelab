This role deploys a new Vault instance and performs the required initialization.
If ran on a client node, it provisions a Vault agent instance instead.

## Prerequisites
- Vault installed
- Terraform installed on Ansible host
- A private key and signed certificate for TLS encryption. If from a self-signed CA,
  the certificate chain must be trusted.
- (Optional) Bitwarden password manager installed

## Initialization

Vault is configured and started. If the instance is uninitialized, the role
performs first-time initialization and stores the root token and unseal key.
Only a single unseal key is supported at the moment. The secrets can be stored
in the filesystem or on Bitwarden.

!!! note
    If storing in Bitwarden, the Bitwarden CLI must be installed and `bw_password`
    variable must be provided.

It then proceeds to login with the root token and setup the PKI secrets engine
and various authentication roles with the Terraform provider. A full list of
Terraform resources can be found at `homelab/terraform/vault`.

!!! warning
    Any existing Vault resources in the same workspace are **destroyed**
    permanently. Take care that the appropriate workspaces are used when
    running the role on multiple Vault server instances.

## Vault Agent

If this role is ran on a client node or `vault_setup_agent` is `true` (on a
server node), it will also provision a Vault-Agent instance. It requires an
existing unsealed Vault server and should be run only after the Vault server has
been setup.

Vault-agent's method of authentication to Vault is TLS certificate
authentication. Ansible will generate these certificates and write them to the
agent's auth role.

!!! note
    This means Ansible requires access to Vault which it receives through
    authentication using its own TLS certificates, created by Terraform during the
    provisioning of the Vault server. These certificates were also written to
    `homelab/certs/`

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| vault_config_dir | Configuration directory | string | `/etc/vault.d` |
| vault_data_dir | Restricted data directory | string | `/opt/vault/data` |
| vault_log_dir | Restricted logs directory | string | `/opt/vault/logs` |
| vault_tls_dir | TLS files directory | string | `/opt/vault/tls` |
| vault_ca_cert_dir | Vault's CA certificate directory | string | `/usr/share/ca-certificates/vault` |
| vault_log_file | Audit log file | string | `${vault_log_dir}/vault.log` |
| vault_store_bw | Store root token in Bitwarden | bool | `false` |
| vault_unseal_key_file | File path for unseal key^ | string | `${vault_data_dir}/.unseal_key` |
| vault_root_token_file | File path for root token^ | string | `${vault_data_dir}/.root_token` |
| vault_terraform_workspace | Terraform workspace | string | `default` |
| vault_admin_password | Password for admin user | string | `password` |
| vault_setup_agent | Setup Vault agent on server node | bool | `true` |
| vault_server_fqdn | Existing Vault server's FQDN | string | `${ansible_default_ipv4.address}` |

>^ Only applicable if `vault_store_bw: false`
