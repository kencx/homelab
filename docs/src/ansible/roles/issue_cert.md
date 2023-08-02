# Issue Cert

This role issues a new Vault certificate from the configured `pki_int` role.

## Prerequisites
- An existing Vault instance
- (Optional) An existing consul-template instance
- Ansible auth certificate on localhost

## Setup
The role issues a new certificate from Vault and writes it to the host's
filesystem at a chosen path. The role logins with an existing Ansible
auth certificate with limited permissions from its configured policies.

The role also optionally adds a consul-template template stanza to automatically
renew the certificate key pair.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| issue_cert_role | Certificate role | string | `client` |
|issue_cert_common_name | Certificate common name | string | `""` |
|issue_cert_ttl | Certificate TTL | string | `24h` |
|issue_cert_vault_addr | Vault instance address | string | `https://localhost:8200` |
|issue_cert_owner | Certificate key pair owner | string | `""` |
|issue_cert_group | Certificate key pair group | string | `""` |
|issue_cert_path | Certificate path | string | `cert.crt` |
|issue_cert_key_path | Private key path | string | `key.pem` |
|issue_cert_ca_path | CA path | string | `ca.crt` |
|issue_cert_auth_role | Auth role to write certificate to | string | `""` |
|issue_cert_auth_policies | Policies to add to auth role | string | `""` |
|issue_cert_add_template | Add consul-template template | boolean | `true` |
|issue_cert_consul_template_config | consul-template config file path | string | `/etc/consul-template/consul-template.hcl` |
|issue_cert_consul_template_marker | consul-template template marker | string | `# {mark} TLS` |
|issue_cert_service | Service to restart after consul-template renews cert | string | `""` |

- `issue_cert_auth_*` variables are only used when `issue_cert_role = "auth"`
