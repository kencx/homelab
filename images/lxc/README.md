# LXC Base Image Pipeline

## Overview
For LXCs, Terraform and Ansible are used to build templates.

1. Terraform provisions a temporary container from a known base image as a starting point
2. Ansible executes the changes in the container
3. Ansible stops the container and creates a template. This is done in the
   Proxmox host.
4. Terraform destroys the temporary container

## Usage

1. Add configuration to `terraform.tfvars` and `../playbooks/vars.yml`.

```bash
$ cp terraform.tfvars.example terraform.tfvars
```

2. Run `make apply`. This will provision a temporary container and execute the
   Ansible playbook on it.

>This will prompt for `pve` sudo password somewhere in the middle.

3. On completion, run `make destroy`.

### Notes
When destroying and recreating a new LXC with the same IP, ensure that the ARP
table is cleared. Otherwise, the recreated host will not be reachable.

If `local-exec` provisioner fails to get successful SSH connection with the temp
LXC, it could be due to the following issues:

- `private_key.pem` is not passed correctly.
- `SSH host checking is still on`

Ensure the Ansible playbook dependencies are installed and updated.

## TODO
- [ ] Add sudo password as encrypted secret
- [ ] `host_vars`
