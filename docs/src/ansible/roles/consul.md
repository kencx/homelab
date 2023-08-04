# Consul

This role deploys a new Consul instance. It can deploy Consul as a server or client,
depending on the host's group name.

## Prerequisites
- An existing Vault instance
- An existing consul-template instance
- Consul installed
- Ansible auth certificate on localhost

## Setup
For encryption, the role creates consul-template templates for:

- Consul's gossip key. A new key is added with `consul keygen` if it does not already
	exist
- Consul TLS certs

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| consul_config_dir | Configuration directory | string | `/etc/consul.d` |
| consul_data_dir | Data directory | string | `/opt/consul` |
| consul_tls_dir | TLS files directory | string | `${consul_data_dir}/tls` |
| consul_template_config_dir | consul-template configuration file | string | `/etc/consul-template` |
| consul_bootstrap_expect | (server only) The expected number of servers in a cluster | number | `1` |
| consul_server_ip | (client only) Server's IP address | string | - |
| consul_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| consul_common_name | Consul node certificate common_name | string | `server.dc1.consul` |
| consul_alt_names | Consul's TLS certificate alt names | string | `consul.service.consul` |
| consul_ip_sans | Consul's TLS certificate IP SANs | string | `127.0.0.1` |
| setup_consul_watches | Set up Consul watches for healthchecks | bool | `true` |
| consul_gotify_url | Gotify URL for sending webhook | string | `""` |
| consul_gotify_token | Gotify token for sending webhook | string | `""` |

## Notes

- `consul_bootstrap_expect` must be the same value in all Consul servers. If the
  key is not present in the server, that server instance will not attempt to
  bootstrap the cluster.
