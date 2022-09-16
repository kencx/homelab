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
- make, pre-commit

## Cluster Details

Packer is used to create images of Debian 11 (bullseye) VMs, with Ansible as a
provisioner.

- A base image is created and used to speedup the process

Terraform is used to deploy the Hashicorp cluster.

- Ansible mounts the required NFS shares to each host

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
