# Prerequisites

## Hardware Requirements

This project can be run on any modern x86_64 system that meets the recommended system
requirements of [Proxmox](https://pve.proxmox.com/wiki/System_Requirements). I
recommend mini-SFF workstations such as those from [Project
TinyMiniMicro](https://www.servethehome.com/introducing-project-tinyminimicro-home-lab-revolution/).
Alternatively, you may choose to run the cluster on a different hypervisor, on
ARM64 systems or entirely on bare metal but YMMV.

My own setup comprises of:

- 1x Intel HP Elitedesk 800 G2 Mini
    - CPU: Intel Core i5-6500T
    - RAM: 16GB DDR4
    - Storage: 256GB SSD (OS), 3TB HDD
- 1x Raspberry Pi 4B+
- TP-Link 5 Port Gigabit Switch

While a separate router and NAS is recommended, I run a virtualized instance of
both within Proxmox itself.

### Networking

The LAN is not restricted to any specific network architecture, but all server
nodes should be reachable by each other, and the controller host via SSH.

The following are optional, but highly recommended:

- A local DNS server that
  [forwards](https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding)
  `service.consul` queries to Consul for DNS lookup. This project uses
  [Coredns](roles/coredns.md).
- A custom domain from any domain registrar, added to Cloudflare as a zone.

## Controller Node

A workstation, controller node or separate host system will be used to run the
required provisioning tools. This system will need to have the following tools
installed:

- Packer
- Terraform
- Ansible
- Python 3 for various scripts (optional)

Alternatively, you are free to install the above tools on the same server that
you are provisioning the cluster.

## Cluster Requirements

- An existing Proxmox server that is reachable by the controller node
- (Optional) An offline, private root and intermediate CA.
- A self-signed certificate, private key for TLS encryption of Vault. A default
  key-pair is
  [generated](https://github.com/hashicorp/vault/blob/main/.release/linux/postinst)
  on installation of Vault.

>**Note**: While Vault can use certificates generated from its own PKI secrets
>engine, a temporary key pair is still required to start up Vault.

<!-- - (Optional) A secure password manager. This project supports [Bitwarden](https://bitwarden.com/) with -->
<!--   custom scripts. -->
