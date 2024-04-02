# Hubble Homelab

**[Documentation](https://kencx.github.io/homelab)**

This repository contains infrastructure-as-code for the automated deployment and
configuration, and management of a Hashicorp (Nomad + Consul + Vault) cluster on
Proxmox.

## Disclaimer

This project is in alpha status and subject to
[bugs](https://kencx.github.io/homelab/references/issues) and breaking changes.

Please do not run any code on your machine without understanding the
provisioning flow, in case of data loss. Some playbooks may perform destructive
actions that are irreversible!

## Overview

This project aims to provision a full Hashicorp cluster in a **semi-automated**
manner. It utilizes Packer, Ansible and Terraform:

1. Packer creates base Proxmox VM templates from cloud images and ISOs
2. Terraform provisions cluster nodes by cloning existing VM templates
3. Ansible installs and configures Vault, Consul, Nomad on cluster nodes

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
- [x] Secrets management, retrieval and rotation with Vault
- [x] Automated certificate management with Vault and consul-template
- [x] Let's Encrypt certificates on Traefik reverse proxy

## Getting Started

See the [documentation](https://kencx.github.io/homelab/getting_started) for more
information on the concrete steps to configure and provision the cluster.

## Folder Structure

```bash
.
├── ansible/
│   ├── roles
│   ├── playbooks
│   ├── inventory    # inventory files
│   └── goss         # goss config
├── bin              # custom scripts
├── packer/
│   ├── base         # VM template from ISO
│   └── base-clone   # VM template from existing template
└── terraform/
    ├── cluster      # config for cluster
    ├── dev          # config where I test changes
    ├── minio        # config for Minio buckets
    ├── modules      # tf modules
    ├── nomad        # nomad jobs
    ├── postgres     # config for Postgres DB users
    ├── proxmox      # config for Proxmox accounts
    └── vault        # config for Vault
```

## Limitations

- Manual Vault unseal on reboot
- Inter-job dependencies are [not supported](https://github.com/hashicorp/nomad/issues/545) in Nomad
- Vault agent is run as root

See [issues]() for more information.

## Acknowledgements

- [CGamesPlay/infra](https://github.com/CGamesPlay/infra)
- [assareh/homelab](https://github.com/assareh/home-lab)
- [RealOrangeOne/infrastructure](https://github.com/RealOrangeOne/infrastructure)
