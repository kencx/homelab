This role deploys a new Consul-template instance.

## Prerequisites
- consul-template installed
- Access to template destination directories

## Setup

Vault-agent is used to authenticate to Vault for consul-template. It only
requires access to the `vault_agent_token_file`. This means consul-template
requires access to Vault directories. It also requires access to any template
destination directories (eg. Consul, Nomad TLS directories). As such, the role
runs consul-template as root. I'm still considering alternatives that allow
consul-template to be ran as a non-privileged user.

!!! note
    Vault and Vault-agent do not have to be installed for the role to run
    successfully. However, they must be available for the consul-template service to
    start without error.

## Variables

| Variable | Description | Type | Default |
| -------- | ----------- | ---- | ------- |
| consul_template_dir | Configuration directory | string | `/opt/consul-template` |
| vault_address | Vault instance IP address | string | `${ansible_default_ipv4.address}` |
