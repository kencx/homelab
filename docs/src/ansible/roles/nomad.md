# Nomad

This role deploys a new Nomad instance. It can deploy Nomad as a server or client,
depending on the host's group name.

## Prerequisites
- An existing Vault instance to save gossip key and provision TLS certs
- An existing consul-template instance to rotate TLS certs
- Nomad installed
- Ansible auth certificate on localhost to access Vault

## Setup
For encryption, the role creates consul-template templates for:

- Nomad's gossip key. A new key is added with `nomad operator gossip keyring
  generate` if it does not already exist
- Nomad TLS certs from Vault PKI
- Vault token for Vault integration

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| nomad_config_dir | Configuration directory | string | `/etc/nomad.d` |
| nomad_data_dir | Data directory | string | `/opt/nomad` |
| nomad_tls_dir | TLS files directory | string | `${nomad_data_dir}/tls` |
| consul_template_config_dir | consul-template configuration file | string | `/etc/consul-template` |
| nomad_register_consul | Register Nomad as a Consul service | bool | `true` |
| nomad_vault_integration | Sets up Vault integration in server node | bool | `true` |
| nomad_server | Start Nomad in server mode | bool | `true` |
| nomad_bootstrap_expect | (server only) The expected number of servers in a cluster | number | `1` |
| nomad_client | Start Nomad in client mode | bool | `false` |
| nomad_server_ip | (client only) Server's IP address | string | - |
| nomad_vault_addr | Vault server API address to use | string | `https://localhost:8200` |
| nomad_common_name | Nomad node certificate common_name | string | `server.global.nomad` |
| nomad_alt_names | Nomad's TLS certificate alt names | string | `nomad.service.consul` |
| nomad_ip_sans | Nomad's TLS certificate IP SANs | string | `127.0.0.1` |
| cni_plugin_version | CNI plugins version | string | `1.3.0` |

## Notes

- `nomad_server` and `nomad_agent` are mutually exclusive and cannot be both
  `true`.
- `nomad_bootstrap_expect` must be the same value in all Nomad servers. If the
  key is not present in the server, that server instance will not attempt to
  bootstrap the cluster.
- An existing Nomad server must be running and reachable at `nomad_server_ip`
  when `nomad_agent` is `true`.
- The default value of `nomad_common_name` is `server.global.nomad` or
  `client.global.nomad` depending on whether nomad is started in server or client
  mode.
