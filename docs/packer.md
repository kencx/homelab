# Packer

Packer uses the community [Proxmox](https://www.packer.io/plugins/builders/proxmox)
builder to create templates.

### Commands
To start building, create a variable file `auto.pkrvars.hcl` and populate it.

```bash
$ cd packer/base
$ packer validate -var-file="auto.pkrvars.hcl" .
$ packer build -var-file="auto.pkrvars.hcl" .
```

## Variables

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

### Notes
- Currently, only `proxmox_username` and `proxmox_password` are supported
- By default, the temporary VM created will use IP `10.10.10.250`.
- The given `vm_id` must be available
- The given `ssh_username` must already exist
