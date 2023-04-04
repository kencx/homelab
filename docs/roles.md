# Ansible Roles

## Common
This role installs common packages and performs standard post-provisioning such
as:
- Creation of user
- Creation of NFS share directories
- Installation of Hashicorp software
- Installation of Bitwarden CLI

>Security hardening and installation of Docker are performed separately in the
>`common.yml` playbook.

### Variables
| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| common_user | User to be created | string | `debian` |
| common_timezone | Timezone to set | string | `Asia/Singapore` |
| common_keyring_dir | Keyring directory path for external apt repositories | string | `/etc/apt/keyrings` |
| common_nfs_dir | NFS share directory path | string | `/mnt/storage` |
| common_packages | List of common packages to be installed | list(string) | See `defaults.yml` for full list |
| common_reset_nomad | Clear Nomad data directory | boolean | `true` |
| common_dotfiles_url | Dotfiles Git repository URL | string | `""` |

## Vault
This role deploys a new Vault instance and performs the required initialization.
If ran on a client node, it provisions a Vault agent instance instead.

### Prerequisites
- Vault installed
- Terraform installed on Ansible host
- A private key and signed certificate for TLS encryption. If from a self-signed CA,
  the certificate chain must be trusted.
- (Optional) Bitwarden password manager installed

### Initialization

Vault is configured and started. If the instance is uninitialized, the role
performs first-time initialization and stores the root token and unseal key.
Only a single unseal key is supported at the moment. The secrets can be stored
in the filesystem or on Bitwarden.

>If storing in Bitwarden, the Bitwarden CLI must be installed and `bw_password`
>variable must be provided.

It then proceeds to login with the root token and setup the PKI secrets engine
and various authentication roles with the Terraform provider. A full list of
Terraform resources can be found at `homelab/terraform/vault`.

### Vault Agent

If this role is ran on a client node or `vault_setup_agent` is `true` (on a
server node), it will also provision a Vault-Agent instance. It requires an
existing unsealed Vault server and should be run only after the Vault server has
been setup.

Vault-agent's method of authentication to Vault is TLS certificate
authentication. Ansible will generate these certificates and write them to the
agent's auth role.

>This means Ansible itself requires access to Vault which it receives through
>authentication using its own TLS certificates, created by Terraform during the
>provisioning of the Vault server. These certificates were also written to
>`homelab/certs/`

### Variables
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

## Consul-template

This role deploys a new Consul-template instance.

### Prerequisites
- consul-template installed
- Access to template destination directories

### Setup

Vault-agent is used to authenticate to Vault for consul-template. It only
requires access to the `vault_agent_token_file`. This means consul-template
requires access to Vault directories. It also requires access to any template
destination directories (eg. Consul, Nomad TLS directories). As such, the role
runs consul-template as root. I'm still considering alternatives that allow
consul-template to be ran as a non-privileged user.

>Vault and Vault-agent do not have to be installed for the role to run
>successfully. However, they must be available for the consul-template service to
>start without error.

### Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| consul_template_dir | Configuration directory | string | `/opt/consul-template` |
| vault_address | Vault instance IP address | string | `${ansible_default_ipv4.address}` |

## Consul

This role deploys a new Consul instance. It can deploy Consul as a server or client,
depending on the host's group name.

### Prerequisites
- An existing Vault instance
- An existing consul-template instance
- Consul installed

### Setup
For encryption, the role creates consul-template templates for:

- Consul's gossip key. A new key is added with `consul keygen` if it does not already
	exist
- Consul TLS certs

### Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| consul_config_dir | Configuration directory | string | `/etc/consul.d` |
| consul_data_dir | Data directory | string | `/opt/consul` |
| consul_tls_dir | TLS files directory | string | `${consul_data_dir}/tls` |
| consul_template_config_dir | consul-template configuration file | string | `/etc/consul-template` |
| consul_bootstrap_expect | (server only) Bootstrap expect | number | `1` |
| consul_server_ip | (client only) Server's IP address | string | - |
| consul_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| consul_common_name | Consul node certificate common_name | string | `server.dc1.consul` |
| consul_alt_names | Consul's TLS certificate alt names | string | `consul.service.consul` |
| consul_ip_sans | Consul's TLS certificate IP SANs | string | `127.0.0.1` |
| setup_consul_watches | Set up Consul watches for healthchecks | bool | `true` |
| consul_gotify_url | Gotify URL for sending webhook | string | `""` |
| consul_gotify_token | Gotify token for sending webhook | string | `""` |

## Nomad
This role deploys a new Nomad instance. It can deploy Nomad as a server or client,
depending on the host's group name.

### Prerequisites
- An existing Vault instance
- An existing consul-template instance
- Nomad installed

### Setup
For encryption, the role creates consul-template templates for:

- Nomad's gossip key. A new key is added with `nomad operator gossip keyring
  generate` if it does not already exist
- Nomad TLS certs
- Vault token for Vault integration

### Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nomad_config_dir | Configuration directory | string | `/etc/nomad.d` |
| nomad_data_dir | Data directory | string | `/opt/nomad` |
| nomad_tls_dir | TLS files directory | string | `${nomad_data_dir}/tls` |
| consul_template_config_dir | consul-template configuration file | string | `/etc/consul-template` |
| setup_vault_integration | Sets up Vault integration in server node | bool | `true` |
| nomad_bootstrap_expect | (server only) Bootstrap expect | number | `1` |
| nomad_server_ip | (client only) Server's IP address | string | - |
| nomad_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| nomad_common_name | Nomad node certificate common_name | string | `server.global.nomad` |
| nomad_alt_names | Nomad's TLS certificate alt names | string | `nomad.service.consul` |
| nomad_ip_sans | Nomad's TLS certificate IP SANs | string | `127.0.0.1` |
