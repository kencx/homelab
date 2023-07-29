[Packer](https://packer.io) is used to create golden images in Proxmox with the
community [Proxmox builder
plugin](https://www.packer.io/plugins/builders/proxmox).

Two different builders are supported: `proxmox-iso` and `proxmox-clone` to
target both ISO and cloud-init images for virtual machine template creation in
Proxmox.

## Proxmox-clone

The `proxmox-clone` builder creates a new VM template from an existing one. This
is best used with an [uploaded cloud image](./cloud_image.md) which has been
converted into a VM template.

This existing template [must
have](https://pve.proxmox.com/wiki/Cloud-Init_Support#_preparing_cloud_init_templates):

- An attached cloud-init drive for the builder to add the SSH communicator
  configuration.
- `cloud-init` installed.

The builder will do the following:

1. Clone existing template.
2. Add a SSH communicator configuration via cloud-init.
3. Connect via SSH and run the shell provisioner scripts to prepare the VM for
   Ansible.
4. Install and start `qemu-guest-agent`.
5. Run the Ansible provisioner with the `ansible/common.yml` playbook.
6. Stop and convert the VM into a template with a new (and empty) cloud-init
   drive.

### Variables

| Variable              | Description                           | Type   | Default |
| ----------------      | ------------------------------------- | ------ | ------- |
| proxmox_url           | Proxmox URL Endpoint                  | string |         |
| proxmox_username      | Proxmox username                      | string |         |
| proxmox_password      | Proxmox pw                            | string |         |
| proxmox_node          | Proxmox node to start VM in           | string | `pve`   |
| clone_vm              | Name of existing VM template to clone | string |         |
| vm_id                 | ID of final VM template               | number | 5000    |
| vm_name               | Name of final VM template             | string |         |
| template_description  | Description of final VM template      | string |         |
| cores                 | Number of CPU cores                   | number | 1       |
| sockets               | Number of CPU sockets                 | number | 1       |
| memory                | Memory in MB                          | number | 1024    |
| ssh_username          | User to SSH into during provisioning  | string |         |
| ip_address            | Temporary IP address of VM template   | string | `10.10.10.250` |
| gateway               | Gateway of VM template                | string | `10.10.10.1` |
| ssh_public_key_path   | Custom SSH public key path            | string |         |
| ssh_private_key_path  | Custom SSH private key path           | string |         |

## Proxmox-ISO

>This builder configuration is a work-in-progress!!

The `proxmox-iso` builder creates a VM template from an ISO file.

### Variables

| Variable         | Description                           | Type   | Default |
| ---------------- | ------------------------------------- | ------ | ------- |
| proxmox_url      | Proxmox URL Endpoint                  | string |         |
| proxmox_username | Proxmox username                      | string |         |
| proxmox_password | Proxmox pw                            | string |         |
| proxmox_node     | Proxmox node to start VM in           | string | `pve`   |
| iso_url          | URL for ISO file to upload to Proxmox | string |         |
| iso_checksum     | Checksum for ISO file                 | string |         |
| vm_id            | ID of created VM and final template   | number | 9000    |
| cores            | Number of CPU cores                   | number | 1       |
| sockets          | Number of CPU sockets                 | number | 1       |
| memory           | Memory in MB                          | number | 1024    |
| ssh_username     | User to SSH into during provisioning  | string |         |

## Build Images

1. Create and populate the `auto.pkrvars.hcl` variable file.

2. Run the build:

```bash
$ packer validate -var-file="auto.pkrvars.hcl" .
$ packer build -var-file="auto.pkrvars.hcl" .
```

If a template of the same `vm_id` already exists, you may force its re-creation
with the `--force` flag:

```bash
$ packer build -var-file="auto.pkrvars.hcl" --force .
```

>This is only available from `packer-plugin-proxmox` v1.1.2.


## Notes
- Currently, only `proxmox_username` and `proxmox_password` are supported for
  authentication.
- The given `ssh_username` must already exist in the VM template when using
  `proxmox-clone`.
