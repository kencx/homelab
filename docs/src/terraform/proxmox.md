# Proxmox

This page describes the Terraform configuration for managing
[Proxmox](https://www.proxmox.com/en/). It uses the
[bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
provider to manage three types of Proxmox resources:

- Access management
- Cloud images
- VMs

<!-- ## Access Management -->
<!---->
<!-- This configuration is found in `terraform/proxmox` and creates a dedicated -->
<!-- Terraform user for the management of Proxmox VMs to be described later. It -->
<!-- defines a `terraform@pam` user in a `Terraform` group which have the minimum -->
<!-- roles required for creating, cloning and destroying VMs. This configuration -->
<!-- requires credentials with at least the `PVEUserAdmin` role (I use the root user -->
<!-- for convenience). -->
<!---->
<!-- After creating the user, we must create an API token in the web console with the -->
<!-- following options: -->
<!---->
<!-- ```text -->
<!-- user: terraform@pam -->
<!-- token_id: some_secret -->
<!-- privilege_separation: false -->
<!-- ``` -->

## Upload of Cloud Images

The same Terraform configuration in `terraform/proxmox` can also be used to
upload cloud images to Proxmox with a given source URL. These images
must have the `.img` extension or Proxmox will fail.

However, these cloud images cannot be used directly by Packer or Terraform to
create VMs. Instead, a template must be created as described in [Cloud
Images](../images/cloud_image.md).

## VM Management

The Terraform configuration in `terraform/cluster` is used to create Proxmox VMs
for the deployment of server and client cluster nodes. It utilizes a custom
module (`terraform/modules/vm`) that clones an existing VM template and
bootstraps it with cloud-init.

>**Note**: The VM template must have cloud-init installed. See
>[Packer](../images/packer.md) for how to create a compatible template.

While root credentials can be used, this configuration accepts an API token
(created previously):

```hcl
provider "proxmox" {
    endpoint = "https://[ip]:8006/api2/json"
    api_token = "terraform@pam!some_secret=api_token"
    insecure = true

    ssh {
      agent = true
    }
}
```

The number of VMs provisioned are defined by the length of the array
variables. The following will deploy four nodes in total: two server and two
client nodes with the given IP addresses. All nodes will be cloned from the
given VM template.

```hcl
template_id = 5003
ip_gateway  = "10.10.10.1"

servers = [
  {
    name       = "server"
    id         = 110
    cores      = 2
    sockets    = 2
    memory     = 4096
    disk_size  = 10
    ip_address = "10.10.10.110/24"
  }
]

clients = [
  {
    name       = "client"
    id         = 111
    cores      = 2
    sockets    = 2
    memory     = 10240
    disk_size  = 15
    ip_address = "10.10.10.111/24"
  }
]
```

On success, the provisioned VMs are accessible via the configured SSH username
and public key.

>**Note**: The VM template must have `qemu-guest-agent` installed and `agent=1`
>set. Otherwise, Terraform will timeout.

### Ansible Inventory
Terraform will also generate an Ansible inventory file `tf_ansible_inventory` in
the same directory. Ansible can read this inventory file automatically by
appending the following in the `ansible.cfg`:

```ini
inventory=../terraform/cluster/tf_ansible_inventory,/path/to/other/inventory/files
```

## Variables

### Proxmox

| Variable               | Description            | Type         | Default    |
| ---------------------- | -----------------------| ------------ | ---------- |
| proxmox_ip             | Proxmox IP address     | string       |            |
| proxmox_user           | Proxmox API token      | string       | `root@pam` |
| proxmox_password       | Proxmox API token      | string       |            |

### VM

| Variable               | Description                                    | Type         | Default    |
| ---------------------- | ---------------------------------------------- | ------------ | ---------- |
| proxmox_ip             | Proxmox IP address                             | string       |            |
| proxmox_api_token      | Proxmox API token                              | string       |            |
| target_node            | Proxmox node to start VM in                    | string       | `pve`      |
| tags                   | List of Proxmox VM tags                        | list(string) | `[prod]` |
| template_id            | Template ID to clone                           | number       |            |
| onboot                 | Start VM on boot                               | bool         | `false`    |
| started                | Start VM on creation                           | bool         | `true`     |
| servers | List of server config (see above) | list(object) | `[]` |
| clients | List of client config (see above) | list(object) | `[]` |
| disk_datastore         | Datastore on which to store VM disk            | string       | `volumes`  |
| control_ip_address     | Control IPv4 address in CIDR notation          | string       |            |
| ip_gateway             | IPv4 gateway address                           | string       |            |
| ssh_username           | User to SSH into during provisioning           | string       |            |
| ssh_private_key_file   | Filepath of private SSH key                    | string       |            |
| ssh_public_key_file    | Filepath of public SSH key                     | string       |            |

- The VM template corresponding to `template_id` must exist
- The IPv4 addresses must be in CIDR notation with subnet masks (eg.
  `10.0.0.2/24`)

## Notes

### Proxmox credentials and LXC bind mounts

Root credentials must be used in place of an API token if you require bind
mounts with an LXC. There is [no
support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
mounts to LXC via an API token.
