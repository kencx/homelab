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
- pre-commit

## Golden Images
All system configuration are implemented on golden images that are provisioned
on all hosts. This prevents configuration drift between systems and allows for
versioned changes that are easy to rollback.

1. Add new configuration to playbook
2. Build the golden image
3. Automated testing on new image
4. Backup all persistent data
5. Destroy existing servers and re-create with new images

## Provisioning
We provision our hosts with Terraform and implement application-specific
configuration with Ansible.

- `provision/cmd` provisions a command environment for running CI/CD pipelines
  with Gitea and Drone.
- `provision/base` is a general base repository that describes a single environment. It can be considered a versioned artifact of an environment's infrastructure.

## Usage
1. (Optional) Provision `cmd` with a chosen base image.

All subsequent steps are executed on `cmd` (or your workstation)

2. Build and test base images
3. Clone `base` folder and pass all relevant environment parameters (dev,
   sit, prod).
4. Provision your environment(s) with their parameters from `base`.

## Notes

#### Proxmox API and LXC bind mounts
>NOTE: Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
>in place of the API token credentials if you require bind mounts. There is [no
>support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
>mounts to LXC via an API token.
