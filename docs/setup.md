This documents the details for setting up a cluster from scratch.

## Vault

A single Vault server instance is configured on a server node. For maximum
resiliency, multiple Vault servers can be started as standby nodes. We use
Vault's [integrated
storage](https://www.vaultproject.io/docs/concepts/integrated-storage) as the
storage backend.

Following [Vault's production hardening
guide](https://learn.hashicorp.com/tutorials/vault/production-hardening?in=vault/day-one-raft),
we try to follow the baseline recommendations for a production ready Vault instance:

- [x] Run as non-root user
- [x] End-to-end TLS
- [ ] Disable swap
- [ ] Disable core dumps
- [ ] Single tenancy
- [ ] Restrict firewall traffic
- [x] Avoid root tokens
- [x] Enable audit logging
- [ ] Disable shell command history
- [x] Restrict storage access
- [x] No clear text credentials
- [x] Use correct file permissions
- [x] Use stdin for Vault secrets
- [x] Use short TTLs

### Prerequisites

- A generated certificate, private key and CA chain from an (offline) private
  root CA and intermediate CA. This is required for TLS encryption for Vault's
  API itself. The CA chain certificate should be added to the system's trust
  store.

  Alternatively, Vault can use certificates generated from its own PKI
  secrets engine as a CA. This still requires a temporary key pair for starting
  the Vault instance.

- A secure password manager. Here, [Bitwarden](https://bitwarden.com/) is used with
  helper scripts `vault/files/bw_store.sh` and `vault/files/bw_get.sh`.

### First Time Setup

1. Vault is started as the `vault` user.
2. Vault is initialized. The root token and unseal key(s) are saved in
   Bitwarden.
3. Login to Vault with the root token and create a root and intermediate CA with
   the PKI secrets engine.
4. Create PKI roles for certificate issuance for mTLS and certificate
   authentication.
5. Enable the file audit device for logging Vault operations.
6. Create a non-root admin policy and identity for secure Vault administration
   and maintenance. It utilizes cert authentication for login.
7. (Optional) If Consul is started, we may enable [Consul integration](#consul-registration) with Vault.
   This requires a certificate key pair to interact with Consul's encrypted API.

## Consul-Template

[Consul-template](https://github.com/hashicorp/consul-template) is used for automated
Vault credentials rotation. This includes:

- Gossip key rotation for Consul and Nomad
- Certificates rotation for Consul, Nomad mTLS
- Client certificates rotation for Nomad, Vault communication with Consul
- Client certificates rotation for Traefik communication with Consul provider
- Vault token for [Vault-Nomad integration](#vault-integration)
- Vault token's accessor for consul-template (see [Token Renewal](#token-renewal))

!!! note
    All nodes running Nomad, Consul or Vault require a consul-template instance.

Consul-template authenticates to Vault via Vault-agent on the same host.

### Prerequisites

- A Vault server instance
- A Vault-agent instance

## Consul

A minimum of two Consul instances are deployed on separate hosts - a server and
a client. The Consul cluster provides service discovery for the cluster with DNS
and HTTP, and integrates with Nomad to provide health checks for applications.

### Prerequisites

- A working Vault server instance with PKI enabled and configured
- A local consul-template instance
- A local DNS server that
  [forwards](https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding#dnsmasq-setup)
  `service.consul` queries to Consul for DNS lookup.

### Setup

1. Set up gossip encryption. A gossip key is generated and saved to Vault, if
   not already present. Gossip key rotation is handled by consul-template.
2. Set up mTLS encryption. A certificate key pair is issued from Vault PKI if
   it does not already exist. Renewal of expired certificates is handled by
   consul-template.
3. Consul is started.

### Consul Registration

Both Vault and Nomad can be integrated with Consul in their respective
configurations. This enables them to leverage on Consul's features including
health checks, service discovery and dynamic configuration. Additionally, we can
use Consul's DNS lookup to easily reference their host IP.

## Nomad

A minimum of two Nomad instances are deployed on separate hosts - a server and a
client - to form a cluster. Ideally, deploying a minimum of three Nomad servers
is recommended to ensure resiliency in the event of a single server failure.

Communication within the Nomad mini-cluster is encrypted:
- Serf or "gossip" traffic for communication between Nomad servers, secured by
  an encryption key.
- HTTP and RPC for communication between Nomad agents, secured by mTLS.

### Prerequisites

- A working Vault server instance
- A local consul-template instance

### Setup

1. On Nomad client hosts, install [CNI
   plugins](https://github.com/containernetworking/plugins/releases/tag/v1.0.0).
   This is necessary to use [bridge networking
   mode](https://developer.hashicorp.com/nomad/docs/job-specification/network#network-modes)
   in Nomad jobspecs.
2. Set up gossip encryption. Similar to Consul, a gossip key is generated and
   saved to Vault, if not already present. This gossip key is added to Nomad's
   configuration and
   [rotated](https://developer.hashicorp.com/consul/tutorials/vault-secure/vault-kv-consul-secure-gossip)
   with consul-template.
3. Set up mTLS encryption. A certificate key pair is issued from the configured
   Vault PKI role if there is no existing pair. Renewal of expired certificates
   is handled by consul-template.
4. [Vault integration](#vault-integration) is enabled.
5. Nomad is started.
6. (Optional) Issue client certificates via Vault for the Nomad CLI. It is also
   useful to setup the relevant environment variables: `NOMAD_ADDR,
   NOMAD_CACERT`.
7. (Optional) If Consul is started, we may enable [Consul
   integration](#consul-registration) in Nomad. This requires a certificate key
   pair to interact with Consul's encrypted API.

### Vault Integration

To access Vault secrets in Nomad jobs, [Vault
integration](https://developer.hashicorp.com/nomad/docs/integrations/vault-integration)
must be enabled. This requires Nomad to have its own periodic, orphan Vault
token, with the relevant policies attached. The token is generated with a custom
token role and passed to Nomad as the `VAULT_TOKEN` environment variable.

It is important to note that both Nomad and consul-template perform renewal of
the Vault token for different reasons which are explained below.

At the moment, we pass the `VAULT_TOKEN` environment variable to Nomad's systemd
service file with the `EnvironmentFile` key and the token in plain text. This
ensures the environment variable is always read when Nomad is started. Nomad
will then handle the renewal of the Vault token in memory without writing the
new token to the file, as long as it has the appropriate policies.

However, if Nomad is restarted after the token in the file has expired, it will
be unable to start. This means the plain text token must be renewed as well.
This renewal is handled by consul-template, which ensures a valid token is
always available on every restart of the Nomad server.
