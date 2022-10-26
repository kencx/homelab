# Setup

This documents the setup details for a cluster from scratch.

- [Vault](#vault)
  - [Prerequisites](#prerequisites)
  - [First Time Setup](#first-time-setup)
- [consul-template](#consul-template)
  - [Setup](#consul-template-setup)
  - [Token Renewal](#token-renewal)
- [Consul](#consul)
- [Nomad](#nomad)
  - [Setup](#nomad-setup)
  - [Vault Integration](#vault-integration)

## Vault

A single Vault server instance is configured on a server node. For maximum
resiliency, multiple Vault servers can be started as standby nodes. We also use
Vault's [integrated
storage](https://www.vaultproject.io/docs/concepts/integrated-storage) as the
storage backend.

### Prerequisites

- A generated certificate, private key and CA chain from an (offline) private
  root CA and intermediate CA. This is required for TLS encryption for Vault's
  API itself. The CA chain certificate should be added to the system's trust
  store.

  Alternatively, Vault can use certificates generated from its own PKI
  secrets engine as a CA. This still requires a temporary key pair for starting
  the Vault instance.

- A password manager where the user is logged in. Here,
  [Bitwarden](https://bitwarden.com/) is used with helper scripts
  `vault/files/bw_store.sh` and `vault/files/bw_get.sh`.

### First Time Setup

1. Start Vault as `vault` user on port 8200.
2. Vault is initialized. The root token and unseal key(s) are saved in
   Bitwarden.
3. We login as root to create a root and intermediate CVA with the PKI secrets
   engine. Multiple roles are created for issuing certificates for Nomad, Consul
   TLS and client cert authentication.
4. The file audit device is enabled for logging Vault operations.
5. A non-root admin policy and identity is created for Vault maintenance. It
   utilizes cert authentication and contains less capabilities than root.

## Consul-Template

[Consul-template](https://github.com/hashicorp/consul-template) is used for automated
Vault credentials rotation. This includes:

- Gossip key rotation for Consul and Nomad
- Certificates rotation for Consul, Nomad mTLS
- Client certificates rotation for Nomad, Vault communication with Consul
- Client certificates rotation for Traefik communication with Consul provider
- Vault token for [Vault-Nomad integration](#vault-integration)
- Vault token's accessor for consul-template (see [Token Renewal](#token-renewal))

All nodes running Nomad, Consul or Vault require a consul-template instance.

### Setup <a name="consul-template-setup"></a>

1. A client certificate and private key is issued from Vault's CA. It is to be used for
   certificate authentication to Vault.
2. Create a new `consul-template` policy and authentication role with the generated
   certificate.
3. Start consul-template as `root` (temporary measure) with login script.
4. Setup cronjob for renew token script.

consul-template requires access to Vault via a Vault token. This is obtained when
authenticating to Vault with any method. Here, we use [certificate
authentication](https://developer.hashicorp.com/vault/docs/auth/cert). A login helper
script is a necessary
[workaround](https://github.com/hashicorp/consul-template/issues/318) for
consul-template to use cert auth to securely access Vault without the need to store the
token in plain text.

#### Token Renewal

consul-template supports automated renewal of its given Vault token. However, cert auth
tokens require passing the client certificate and key during renewal and hence, are not
supported. As such, we use a renew token helper script with a periodic cronjob instead.
When consul-template starts, it performs a self-lookup on the token, generated from the
login script, that stores the accessor ID. The helper script uses this accessor ID to
renew the token when triggered.

## Consul

#### Security
Consul is started with mTLS. As such, all clients are required to possess a
signed certificate from the same CA (Vault's CA):

- Consul client nodes
- CLI client on all hosts
- Consul UI
- Vault server
- Nomad server and client nodes

#### Consul Registration

TODO

#### Setup

TODO

## Nomad

#### Setup <a name="nomad-setup"></a>

1. Client certificates are issued via Vault to all Nomad nodes to enable mTLS
   encryption. consul-template handles all renewal of expired certificates.
2. The gossip key is obtained from Vault to enable gossip encryption. If there is no
   existing key, a new key is generated.
3. [Vault integration](#vault-integration) is enabled.
4. The Nomad node is started with server or client dependent configuration.
5. (Optional) Client certificates are issued via Vault for CLI interaction with the
   Nomad API. It is also useful to setup the relevant environment variables:
   `NOMAD_ADDR, NOMAD_CACERT`.

#### Vault Integration

To access Vault secrets in Nomad jobs, [Vault
integration](https://developer.hashicorp.com/nomad/docs/integrations/vault-integration)
must be enabled. This requires Nomad to have its own periodic, orphan Vault token, with
relevant policies attached. The token is generated with a custom token role. It is then
passed to Nomad as the `VAULT_TOKEN` environment variable.

Both Nomad and consul-template perform renewal of the Vault token, but for different
reasons. The token is placed in a plain text file, to be read by systemd as an
`EnvironmentFile` for the Nomad service. On the token's expiry, Nomad will renew it in
memory without writing the new token to the file.

However, if Nomad is restarted after the token in the file has expired, Nomad is unable
to produce a new token for startup automatiicaly. As such, consul-template writes a new
plain text token in the file when it expires, ensuring a valid token is always available
on every restart of the Nomad server.
