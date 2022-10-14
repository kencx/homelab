# Setup

This documents the setup details for a cluster from scratch.

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
