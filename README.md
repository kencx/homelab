# Hubble Homelab

This repository contains infrastructure-as-code for the automated deployment and
management of a Hashicorp (Nomad + Consul + Vault) cluster. The cluster is
hosted on Proxmox as a personal, private homelab.

## Disclaimer
This project is in pre-alpha status and subject to breaking changes. Please:

- Do read the documentation.
- Do not run any code on your machine directly as is, in case of data loss. Some
  playbooks may perform destructive actions that are irreversible!
- Do use this repository for ideas or as an example for your own homelab setup.

## Overview

The cluster is provisioned on multiple Debian VMs on a single Proxmox instance. It comprises
minimally of one server node and one client node with NFS mounted storage from a separate
NAS instance.

### Features
- [x] Golden image creation with Packer
- [x] Declarative configuration of Vault with Terraform
- [x] Automated post-provisioning with Ansible
- [x] Nomad container scheduling and orchestration
- [x] Consul service discovery
- [x] Secure node communication via mTLS
- [x] Personal Certificate Authority hosted on Vault
- [x] Automated certificate management with Vault and consul-template
- [x] Let's Encrypt certificates on Traefik reverse proxy
- [x] Scheduled, automated backups with Restic and Autorestic

## Provisioning

This repository aims to provision a functional cluster from scratch with manual
intervention. It uses:

- Packer for creating golden images in Proxmox
- Terraform for deploying Proxmox VMs and/or LXCs
- Ansible for configuration management

The cluster requires a minimum of two hosts: one server and one client node.

### Golden Images with Packer

Packer's
[Proxmox](https://developer.hashicorp.com/packer/plugins/builders/proxmox)
builder is used to build a base Proxmox VM template from an existing Debian 11
cloud image. It clones an existing template and uses Ansible to execute common
provisioning tasks such as installing common packages and security hardening. On
completion, the VM is converted into a Proxmox template.

>Packer can also build images from an ISO with `proxmox-iso`. This is currently a
>work-in-progress.

### Provisioning with Terraform

Terraform provisions Proxmox VMs from the previously-created golden images with
the
[telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
provider. It utilizes cloud-init to set up the host's hostname, user and SSH
access keys.

### Post-provisioning with Ansible

Finally, Ansible configures and starts the Hashicorp software necessary to run a
functional cluster. The Ansible playbooks use modular and independent roles to
set up hosts as a server or client node.

On server nodes,

1. Vault is initialized with TLS encryption. After unsealing, first-time
   setup is performed with the root token and Terraform.
2. Consul-template is configured with limited access to Vault via Vault-agent.
3. Nomad and Consul are configured with mTLS encryption in server mode.
4. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

On client nodes, after the server nodes are up,

1. Consul-template is configured with limited access to the remote Vault server
   via Vault-agent.
2. Nomad and Consul are configured with mTLS encryption in client mode.
3. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

## TODO
- [ ] systemd notification on failure
- [ ] Monitoring stack on separate node
- [ ] Nomad, Consul ACLs
- [ ] Run consul-template as non-root user
- [ ] Nomad, Consul automated gossip key rotation
- [ ] CI/CD pipeline for provisioning steps
- [ ] Wireguard VPN
