# Ansible Roles

## Vault
This role deploys a new Vault instance and performs the required initialization.

### Prerequisites
- A private key and signed certificate for TLS encryption. If from a self-signed CA, the
	system must also contain and recognize the CA certificate or certificate chain.
- Vault installed
- Bitwarden password manager

### Initialization
After Vault initialization, the role records the root token and unseal key(s) into
Bitwarden for reference when required. It logs in as root to setup Vault as a
self-signed CA with the PKI secrets engine. The role also creates an admin policy and
cert auth role for secure non-root access of Vault by an administrator.

### Variables
| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| vault_config_dir | Configuration directory | string | `/etc/vault.d` |
| vault_data_dir | Restricted data directory | string | `/opt/vault/data` |
| vault_tls_dir | TLS files directory | string | `/opt/vault/tls` |
| vault_ca_cert_dir | Vault's CA certificate directory | string | `/usr/share/ca-certificates/vault` |
| vault_policy_dir | Policies directory | string | `{{ vault_config_dir }}/policies` |
| vault_log_file | Audit log file | string | `{{ vault_data_dir }}/vault.log` |

## Consul-template

This role deploys a new Consul-template instance.

### Prerequisites
- An existing Vault instance
- consul-template installed
- Access to Vault TLS directories
- Access to template destination directories

### Setup
The role creates a new consul-template policy and cert auth role for access to Vault. A
login helper script is used to access Vault securely, without saving the resulting token
as plain text on the system.

If a consul-template cert auth role already exists, it should use the existing
certificates instead of generating its own. As of now, this is done by mounting an NFS
share with the certificate and private key on the server and client instance. This is a
temporary measure until something safer is implemented. The cert auth role for
consul-template also renews its own certificates on expiry.

At the moment, this role runs consul-template as root. This is required because
consul-template requires access to Vault's TLS directories for connection to the
encrypted Vault instance and access to any template's destination directories (which are
the Consul and Nomad TLS directories). I'm still considering alternatives that allow
consul-template to be ran as a non-privileged user.

### Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| consul_template_dir | Configuration directory | string | `/opt/consul-template` |
| vault_login_script | Login script path | string | `{{ consul_template_dir }}/login.sh` |
| vault_address | Vault instance IP address | string | `{{ ansible_default_ipv4.address }}` |
| vault_tls_dir | TLS files directory | string | `/opt/vault/tls` |
| vault_policies_dir | Vault Policies directory | string | `/etc/vault.d/policies` |

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
| consul_tls_dir | TLS files directory | string | `{{ consul_data_dir }}/tls` |
| consul_template_config | consul-template configuration file | string | `/opt/consul-template/consul_template.hcl` |
| consul_bootstrap_expect | (server only) Bootstrap expect | number | `1` |
| consul_server_ip | (client only) Server's IP address | string | - |
| consul_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| consul_common_name | Consul node certificate common_name | string | `server.dc1.consul` |
| consul_ip_sans | Consul's TLS certificate IP SANs | string | `127.0.0.1` |

## Nomad
This role deploys a new Nomad instance. It can deploy Nomad as a server or client,
depending on the host's group name.

### Prerequisites
- An existing Vault instance
- An existing consul-template instance
- Nomad installed

### Setup
For encryption, the role creates consul-template templates for:

- Nomad's gossip key. A new key is added with `nomad operator keygen` if it does not already
	exist
- Nomad TLS certs
- Vault token for Vault integration

### Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nomad_config_dir | Configuration directory | string | `/etc/nomad.d` |
| nomad_data_dir | Data directory | string | `/opt/nomad` |
| nomad_tls_dir | TLS files directory | string | `{{ nomad_data_dir }}/tls` |
| consul_template_config | consul-template configuration file | string | `/opt/consul-template/consul_template.hcl` |
| setup_vault_integration | Sets up Vault integration in server node | bool | `true` |
| vault_policy_dir | Vault server policy directory | string | `/etc/vault.d/policies` |
| nomad_bootstrap_expect | (server only) Bootstrap expect | number | `1` |
| nomad_server_ip | (client only) Server's IP address | string | - |
| nomad_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| nomad_common_name | Nomad node certificate common_name | string | `server.global.nomad` |
| nomad_ip_sans | Nomad's TLS certificate IP SANs | string | `127.0.0.1` |
