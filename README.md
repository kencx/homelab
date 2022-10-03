# Hubble Homelab
This repository contains all infrastructure-as-code and configuration for my Proxmox
homelab and Hetzner VPS. It provisions a Nomad + Consul cluster for running various
services.

## Requirements
- Proxmox VE 7.1
- Packer
- Ansible
- Terraform
- Goss
- restic, autorestic

## Cluster
The cluster exists on a single Proxmox host with multiple Debian VMs.

The cluster creation process is a declarative, fully automated process with
Packer, Ansible and Terraform. At the moment, not all processes are fully
idempotent.

Our end goal is a fully functional Nomad and Consul cluster with secure access
to Vault:

- All Nomad, Consul and Vault nodes should be discoverable by Consul.
- Clients should communicate with their server nodes via TLS.


### Image Creation
A base Debian 11 (bullseye) image is created with Packer and Ansible. It installs common
packages, perform basic security hardening and creates the necessary directories for
mounting of NFS shares.

### Provisioning
A cluster of VMs are provisioned with Terraform. Two types of VMs are created from the
base image: server and client. They differ in the later post-provisioning steps
performed by Ansible. Multiples are type of VM can be started.

For server hosts, Ansible performs the following:

0. A root CA and intermediate CA is created on the controller node if they do not
	 already exist. This CA will then deploy TLS certificates to be used by Vault.
1. Vault is configured and started with TLS encryption. Vault is then initialized and
	 unsealed for [first-time setup and hardening](#vault-first-time-setup). On successful
	 setup, future logins to Vault will be using a non-root admin identity with TLS cert
	 authentication.
2. Consul-template is configured and started with limited access to Vault. It will be
	 used for Vault credential rotation in Consul and Nomad.
3. Consul is configured and started with gossip and TLS encryption in server mode.
4. Nomad is configured and started with gossip and TLS encryption in server mode.
5. Vault is restarted to allow for service discovery by Consul.
6. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

For client hosts, Ansible performs the following, after post-provisioning of servers:

0. One or more new client certificate pair will be generated from Vault PKI for client
	 access to the remote Vault instance. Their associated policies can be tweaked for the
	 use case.
1. Consul-template is configured and started with limited access to Vault. This should
	 use the previously generated client certificates for authentication.
2. Consul is configured and started with gossip and TLS encryption in client mode.
3. Nomad is configured and started with gossip and TLS encryption in client mode.
4. NFS shares are mounted from the remote NAS server.
5. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

Finally, we can provision all Nomad jobs in `apps/`.

#### Vault First Time Setup
1. We initialize Vault for the first time, saving the root token and unseal keys
	 into a password manager. The root token is used to login as root.
2. A root and intermediate CA is created with the PKI secrets engine for
	 certificate generation. We create roles for deploying Nomad and Consul TLS
	 certificates, and for client cert authentication.
3. An non-root admin policy and identity is created. It utilizes cert
	 authentication and contains only the required capabilities to perform
	 maintenance.
4. Other policies are created including those used by Consul-template for
	 certificate rotation, retrieving secrets etc.

## VPS
A Hetzner VPS is provisioned to run various web applications. It is bootstrapped
with `cloud-config` and exposed via a Nginx reverse proxy.

## Backups
Autorestic performs daily backups to an external USB hard drive and Backblaze
B2.

## Matrix
| Service  | Status     | Comments        |
|----------| ---------- | --------------- |
| Nomad    | Production |     |
| Consul   | Production |     |
| Vault    | Production |     |

## Notes

#### Proxmox API and LXC bind mounts
>NOTE: Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
>in place of the API token credentials if you require bind mounts. There is [no
>support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
>mounts to LXC via an API token.
