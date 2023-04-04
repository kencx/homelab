# Hubble Homelab

This repository contains infrastructure-as-code and configuration for the automated
provisioning of my Proxmox homelab. It provisions a Nomad + Consul + Vault mini-cluster
for personal use.

## Overview

The cluster is provisioned on multiple Debian VMs on a single Proxmox instance. It comprises
minimally of one server node and one client node with NFS mounted storage from a separate
NAS instance.

### Features
- [x] Nomad container scheduling and orchestration
- [x] Consul service discovery
- [x] Secure node communication via mTLS
- [x] Personal Certificate Authority hosted on Vault
- [x] Automated certificate management with consul-template, Traefik

## Provisioning

The infrastructure-as-code in this project aims to allow the user to provision a fully
functional cluster from scratch with minimal manual intervention. The cluster requires
at least two hosts: one server and one client node.

The three key provisioning steps are:

1. VM image creation with Packer & Ansible
2. Provisioning with Terraform
3. Post-provisioning with Ansible

### Packer Image Creation

Each VM is provisoned from a common base Debian 11 image created with Packer and
Ansible, as seen in `packer/base-clone`. The templating process installs common packages,
performs security hardening and other common tasks.

Refer to [docs/packer](docs/packer.md) for more information.

### Provisioning with Terraform

Terraform provisons VMs from the created images on Proxmox with the
[telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
provider. All resources utilize a custom `base` module in which contains sane
defaults and sets up SSH access.

Configuration variables for `base` are found at [docs/terraform](docs/terraform.md).

### Post-provisioning with Ansible

Post-provisioning is performed on each host with Ansible playbooks. These playbooks use
modular and independent [roles](docs/roles.md) to set up software configurations in
each node, depending on their type.

On server nodes,

1. Vault is started and initialized with TLS encryption. After unsealing, first-time
   setup is performed with the root token.
2. Consul-template is configured with limited access to Vault. It will be the main tool
   to automate Vault credential rotation.
3. Nomad and Consul are configured with mTLS encryption in server mode.
4. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

On client nodes, after the server playbooks are run,

1. Consul-template is configured with limited access to the remote Vault server.
2. Nomad and Consul are configured with mTLS encryption in client mode.
3. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).
4. All Nomad jobs in `apps/` are provisioned.

Refer to [docs/setup](docs/setup.md) for detailed information.

## VPS

A Hetzner VPS is provisioned to run various web applications. It is bootstrapped
with `cloud-config` and exposed via a Nginx reverse proxy.

## Backups

Autorestic performs daily backups to an external USB hard drive and Backblaze
B2.

## Notes

#### Proxmox API and LXC bind mounts
>NOTE: Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
>in place of the API token credentials if you require bind mounts. There is [no
>support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
>mounts to LXC via an API token.
