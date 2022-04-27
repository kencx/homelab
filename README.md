# Homelab Infrastructure
This repository contains Terraform code and Ansible playbooks for my Proxmox VE
7 homelab.

## Features
- Automated golden image builds for LXCs and VMs
- Declarative and idempotent provisioning

## Requirements
- Proxmox VE 7
- Terraform
- Ansible (and molecule)
- Docker and docker-compose
- make
- pre-commit

## Golden Images
A key goal for this homelab is immutable infrastructure -
servers are never modified directly once they are deployed. Instead, all
configuration changes are implemented on golden images that are subsequently
provisioned on all systems. This prevents configuration drift between systems
and allows for versioned changes that are easy to rollback.

Refer to
[docs/images.md](https://github.com/kencx/homelab-iac/blob/master/docs/images.md)
for more details.

## Provisioning
We provision our hosts with Terraform and implement application-specific
configuration with Ansible.

- `terraform/cmd` provisions a command environment for running CI/CD pipelines
  with Gitea and Drone.
- `terraform/base` is a general base repository that describes a single environment. It can be considered a versioned artifact of an environment's infrastructure.

## Notes

#### Proxmox API and LXC bind mounts
>NOTE: Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
>in place of the API token credentials if you require bind mounts. There is [no
>support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
>mounts to LXC via an API token.
