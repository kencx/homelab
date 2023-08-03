# Proxmox

The
[telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
provider is used by Terraform to communicate with the Proxmox API. The provider
must be configured appropriately:

```hcl
provider "proxmox" {
  pm_api_url  = var.proxmox_ip
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}
```

## Overview

The Terraform configuration in `terraform/cluster` is used to deploy server and
client cluster nodes. It uses a custom module (`terraform/modules/vm`) that
clones an existing VM template and bootstraps it with cloud-init.

>**Note**: The VM template must have cloud-init installed. See
>[Packer](../images/packer.md) for how to create a compatible template.

The number of nodes provisioned are defined by the length of the array
variables. The following will deploy four nodes in total: two server and two
client nodes with the given IP addresses. All nodes will be cloned from the
given VM template.

```hcl
template_name = "base"
server_vmid      = [110, 111]
client_vmid      = [120, 121]
server_ip_address = ["10.10.10.110/24", "10.10.10.111/24"]
client_ip_address = ["10.10.10.120/24", "10.10.10.121/24"]
ip_gateway        = "10.10.10.1"
```

On success, the provisioned VMs are accessible via the configured SSH username
and key pair.

## Ansible Inventory
Terraform will also generate an Ansible inventory file `tf_ansible_inventory` in
the same directory. Ansible can read this inventory file automatically by
appending the following in the `ansible.cfg`:

```ini
inventory=../terraform/cluster/tf_ansible_inventory,/path/to/other/inventory/files
```

## Variables

### VM

| Variable               | Description                                    | Type         | Default    |
| ---------------------- | ---------------------------------------------- | ------------ | ---------- |
| proxmox_ip             | Proxmox IP address                             | string       |            |
| proxmox_user           | Proxmox username                               | string       | `root@pam` |
| proxmox_password       | Proxmox pw                                     | string       |            |
| target_node            | Proxmox node to start VM in                    | string       | `pve`      |
| tags                   | Proxmox VM tags                                | string       | `prod`     |
| template_name          | Proxmox VM template to clone                   | string       |            |
| onboot                 | Start VM on boot                               | bool         | `false`    |
| oncreate               | Start VM on creation                           | bool         | `true`     |
| server_hostname_prefix | Hostname prefix for all server nodes           | string       | `server`   |
| server_vmid            | List of server VM IDs                          | list(number) |            |
| server_cores           | Number of cores for all server nodes           | number       | `2`        |
| server_sockets         | Number of sockets for all server nodes         | number       | `2`        |
| server_memory          | Total memory for all server nodes (MB)         | number       | `2048`     |
| server_disk_size       | Disk size in all server nodes                  | string       | `5G`       |
| client_hostname_prefix | Hostname prefix for all client nodes           | string       | `client`   |
| client_vmid            | List of client VM IDs                          | list(number) |            |
| client_cores           | Number of cores for all client nodes           | number       | `2`        |
| client_sockets         | Number of sockets for all client nodes         | number       | `2`        |
| client_memory          | Total memory for all client nodes (MB)         | number       | `2048`     |
| client_disk_size       | Disk size in all client nodes                  | string       | `5G`       |
| server_ip_address      | List of server IPv4 addresses in CIDR notation | list(string) |            |
| client_ip_address      | List of client IPv4 addresses in CIDR notation | list(string) |            |
| ip_gateway             | IPv4 gateway address                           | string       |            |
| disk_storage_pool      | Storage pool on which to store VM disk         | string       | `volumes`  |
| ssh_username           | User to SSH into during provisioning           | string       |            |
| ssh_private_key_file   | Filepath of private SSH key                    | string       |            |
| ssh_public_key_file    | Filepath of public SSH key                     | string       |            |

- `*_disk_size` must match the regex `\d+[GMK]`.
- The VM template corresponding to `template_name` must be exist.
- The length of `server_vmid` and `server_ip_address` must be equal. Each
  element in the latter corresponds to the IP address of the latter. The same
  applies for the client arrays.
- The lists of IPv4 addresses must be in CIDR notation with subnet masks.

## Notes

### Inconsistent Disk Changes

There is an [existing
bug](https://github.com/Telmate/terraform-provider-proxmox/issues/700) that may
cause Terraform plans to add additional disks that are not configured. The bug
is inconsistent and appears to be random.

### Proxmox credentials and LXC bind mounts

Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
in place of the API token credentials if you require bind mounts. There is [no
support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
mounts to LXC via an API token.
