Terraform uses the
[telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
provider to communicate with the Proxmox API. The `proxmox` provider must be
configured appropriately.

```tf
provider "proxmox" {
  pm_api_url  = var.proxmox_ip
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}
```

## Overview

There are two custom modules available `terraform/modules/{vm,lxc}` for
provisioning a VM and LXC respectively.

Cluster nodes are provisioned with the `vm` module. Each resource has a
`null_resource` with a `local_exec` provisioner that calls its Ansible playbook.
These provisioners are triggered by changes in their configured Ansible playbooks.

## Deployment

To start the deployment, ensure all variables are appropriately populated in
`terraform.tfvars`.

```bash
$ cd terraform/cluster
$ terraform init
$ terraform plan
$ terraform apply
```

## Variables

### VM

| Variable             | Description                          | Type   | Default    |
| -------------------- | ------------------------------------ | ------ | ---------- |
| proxmox_ip           | Proxmox IP address                   | string |            |
| proxmox_user         | Proxmox username                     | string | `root@pam` |
| proxmox_password     | Proxmox pw                           | string |            |
| target_node          | Proxmox node to start VM in          | string | `pve`      |
| hostname             | Hostname of VM                       | string | `base`     |
| vmid                 | ID of created VM and                 | number | `4000`     |
| template_name        | Template to clone                    | string |            |
| onboot               | Start VM on boot                     | bool   | `false`    |
| oncreate             | Start VM on creation                 | bool   | `true`     |
| cores                | Number of CPU cores                  | number | 1          |
| sockets              | Number of CPU sockets                | number | 1          |
| memory               | Memory in MB                         | number | 1024       |
| ssh_username         | User to SSH into during provisioning | string |            |
| ssh_private_key_file | Filepath of private SSH key          | string |            |
| ssh_public_key_file  | Filepath of public SSH key           | string |            |

## Notes

- The given `template_name` must be exist. This should be the same name in
  Packer.

### Proxmox credentials and LXC bind mounts

Credentials `proxmox_user="root@pam"` and `proxmox_password` must be used
in place of the API token credentials if you require bind mounts. There is [no
support](https://bugzilla.proxmox.com/show_bug.cgi?id=2582) for mounting bind
mounts to LXC via an API token.
