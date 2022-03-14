# Homelab
This repository details the Infrastructure as Code (IaC) for my Proxmox VE 7 homelab.

It consists of:
- Automated creation of VM & LXC base images.
- Declarative provisioning of virtual VMs & LXCs

## Images
All configuration changes must happen on base images.

Change process:
1. Manual test and tinker on dev server
2. Perform automated builds of changes with Ansible
3. Save the base image
4. Perform automated tests on new base image
5. Ensure all persistent data is available in persistent storage
6. Destroy existing servers and re-create with new templates
7. Monitor for configuration drift

#### LXCs
Terraform and Ansible are used to build LXC templates.

1. Terraform provisions a temporary container from a known base image as a starting point
2. Ansible executes the changes in the container
3. Ansible stops the container and creates a template. This is done in the
   Proxmox host.
4. Terraform destroys the temporary container

#### VMs
1. Packer builds a VM from a declarative Packer file.
2. Ansible performs post-provisioning.
3. Packer saves the VM image.

## Provisioning
All infrastructure is defined in Terraform. With immutable infrastructure, no
configuration changes should be happening in the server.

However, some VMs/containers are catered for one piece of software. For such
hosts, Ansible is used to perform software-specific configuration that changes
frequently.
