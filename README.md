# Hubble Homelab

**[Documentation](https://kencx.github.io/homelab)**

This repository contains infrastructure-as-code for the automated deployment and
configuration and management of a Hashicorp (Nomad + Consul + Vault) cluster.
The cluster is hosted on Proxmox as a personal, private homelab.

## Disclaimer

This project is in pre-alpha status and subject to breaking changes. Please do
not run any code on your machine without understanding the provisioning flow, in
case of data loss. Some playbooks may perform destructive actions that are
irreversible!

## Overview

This project aims to provision a full Hashicorp cluster in a semi-automated
manner. It utilizes Packer, Ansible and Terraform:

- Packer creates base Proxmox VM templates from cloud images and ISOs
- Terraform provisions cluster nodes by cloning existing VM templates
- Ansible installs and configures Vault, Consul, Nomad on cluster
  nodes

It comprises minimally of one server and one client node with no high
availability (HA). The nodes run Vault, Consul and Nomad as a cluster.

To support HA, the setup can be further expanded to at least three server nodes
and multiple client nodes hosted on a Proxmox cluster, spanning multiple
physical machines.

## Features

- [x] Golden image creation with Packer
- [x] Declarative configuration of Proxmox VMs and Vault with Terraform
- [x] Automated post-provisioning with Ansible
- [x] Nomad container scheduling and orchestration
- [x] Consul service discovery
- [x] Secure node communication via mTLS
- [x] Personal Certificate Authority hosted on Vault
- [x] Automated certificate management with Vault and consul-template
- [x] Let's Encrypt certificates on Traefik reverse proxy
- [x] Scheduled, automated backups with Restic and Autorestic

## Getting Started

See the [documentation](https://kencx.github.io/homelab/getting_started) for more
information on the concrete steps to configure and provision the cluster.

## Acknowledgements

- [CGamesPlay/infra](https://github.com/CGamesPlay/infra)
- [assareh/homelab](https://github.com/assareh/home-lab)
- [RealOrangeOne/infrastructure](https://github.com/RealOrangeOne/infrastructure)
