# Vault

This role deploys a new Vault instance and performs the required initialization.
If ran on a client node, it provisions a Vault agent instance instead.

## Prerequisites
- Vault >1.14.0 installed
- Terraform installed on Ansible host
- A private key and signed certificate for TLS encryption. If from a self-signed CA,
  the certificate chain must be trusted.
- (Optional) Bitwarden password manager installed

## Initialization

Vault is configured and started. If the instance is uninitialized, the role
performs first-time initialization and stores the root token and unseal key.
Only a single unseal key is supported at the moment. The secrets can be stored
in the filesystem or on Bitwarden.

>**Note**: If storing in Bitwarden, the Bitwarden CLI must be installed,
>configured and the `bw_password` variable must be provided.

It then proceeds to login with the root token and setup the PKI secrets engine
and various authentication roles with the Terraform provider. A full list of
Terraform resources can be found at `homelab/terraform/vault`.

>**Warning**: Any existing Vault resources in the same workspace are
>**destroyed** permanently. Take care that the appropriate workspaces are used
>when running the role on multiple Vault server instances.

## Vault Agent

If this role is ran on a client node or `vault_setup_agent` is `true` (on a
server node), it will also provision a Vault-Agent instance. It requires an
existing unsealed Vault server and should be run only after the Vault server has
been setup.

Vault-agent's method of authentication to Vault is TLS certificate
authentication. Ansible will generate these certificates and write them to the
agent's auth role.

>**Note**: This means Ansible requires access to Vault which it receives through
>authentication using its own TLS certificates, created by Terraform during the
>provisioning of the Vault server. These certificates were also written to
>`homelab/certs/`

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| vault_config_dir | Configuration directory | string | `/etc/vault.d` |
| vault_data_dir | Restricted data directory | string | `/opt/vault/data` |
| vault_log_dir | Restricted logs directory | string | `/opt/vault/logs` |
| vault_tls_dir | TLS files directory | string | `/opt/vault/tls` |
| vault_ca_cert_dir | Vault's CA certificate directory | string | `/usr/share/ca-certificates/vault` |
| vault_server | Setup Vault server | bool | true |
| vault_log_file | Audit log file | string | `${vault_log_dir}/vault.log` |
| vault_store_local | Copy Vault init secrets to local file | bool | `true` |
| vault_secrets_file | File path for Vault init secrets | string | `vault.txt` |
| vault_store_bw | Store root token in Bitwarden | bool | `false` |
| vault_terraform_workspace | Terraform workspace | string | `default` |
| vault_admin_password | Password for admin user | string | `password` |
| vault_register_consul | Register Vault as a Consul service | bool | `true` |
| vault_setup_agent | Setup Vault agent | bool | `true` |
| vault_server_fqdn | Existing Vault server's FQDN | string | `${ansible_default_ipv4.address}` |

## Notes

- `vault_server` and `vault_setup_agent` are not mutually exclusive. A host
  can have both instances running at the same time. However, there must already
  be an existing server instance if `vault_server` is `false`.
- `vault_server_fqdn` is used to communicate with an existing Vault server that
  is listening on port 8200 when setting up Vault agent.

### Vault Initialization Secrets

This role offers two methods of storing the secrets generated (root token and
unseal key(s)) during the initial Vault initialization:

- On the Ansible host system
- In Bitwarden
- Both

Storing the secrets on the local filesystem is only recommended as a temporary
measure (to verify the secrets), or for testing and development. The file should
be deleted afterwards or moved to a safer location.

>**Warning**: The Bitwarden storage functionality is not very robust and not
>recommended at the moment. Use it with caution.

Storing the secrets in Bitwarden requires the following prerequisites:
- Bitwarden CLI tool must be installed and configured
- User is logged into Bitwarden
- `bw_password` variable must be defined and passed to Ansible safely

The `bw_get.sh` and `bw_store.sh` helper scripts are used to create or update
the secrets. Take care that the scripts will overwrite any existing secrets (of
the same name).
