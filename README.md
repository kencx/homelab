# Homelab
This project builds and configures my Proxmox VE 7 homelab with Infrastructure
as Code.

It consists of two key parts:
1. Automated creation of base images
2. Declarative provisioning of hosts

## Tools
- Terraform
- Ansible
- Packer

## Base Images
Base images of our hosts are built and tested to practice Immutable
Infrastructure. A general workflow is as follows:

1. Manual tinkering on dev server
2. Automate changes with Ansible
3. Save the base image
4. Automated testing on new base image
5. Ensure all persistent data is available in persistent storage
6. Destroy existing servers and re-create with new base images

All code is situated within `images`. Refer to `images/README.md` for more
details.

## Provisioning
A `controller` host is deployed to perform all subsequent provisioning. While
our workstation can be used, I chose to execute all such tasks on a particular
VM on the same subnet. It clones and deploys `skeleton` through CI/CD with the
relevant environment parameters.

All code is within `provision`. Refer to `provision/README.md` for more details.

## Usage
### Pre-requisites
Tested on:
- Proxmox VE 7.2
- Terraform v1.1.7
- Ansible v2.12.3
- Molecule v3.5.2
- Docker v20.10.14
- pre-commit v2.17.0

### pre-commit
- Run terraformfmt and terraformdocs
- Run molecule tests
- Ensure no secrets are committed.

### Steps
1. (Optional) Provision `controller` with a chosen base image.

All subsequent steps are executed on `controller` (or your workstation)
2. Build and test base images
3. Clone `skeleton` folder and pass all relevant environment parameters (dev,
   sit, prod).
4. Provision your environment(s) with their parameters from `skeleton`.
