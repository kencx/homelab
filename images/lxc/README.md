# LXC Base Image Pipeline
Ansible is used to build LXC templates.

A temporary LXC container is created and bootstrapped. After configuration, it
is stopped and Proxmox creates a template with `vzdump`, before deleting the
container.

## Usage

1. Add configuration to `./vars.yml` and `../playbooks/vars.yml`

2. Ensure hosts file is defined. By default, we use the the global hosts file at
   `${BASE_DIR}/inventory/hosts.yml`.

3. Run `make bootstrap`.

>This will prompt for `pve` sudo password.

### Notes
When destroying and recreating a new LXC with the same IP, ensure that the ARP
table is cleared. Otherwise, the recreated host will not be reachable.

Ensure the Ansible playbook dependencies are installed and updated. Run `make
galaxy-install`.
