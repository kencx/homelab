# Terraform

## Prerequisites
- `telmate/proxmox` provider
- Terraform v1.3.0

## Modules
There are two Terraform modules available at `terraform/modules`: `vm` and `lxc` for a
Proxmox VM and LXC respectively.

## Cluster
The main Hubble cluster utilizes the `vm` module to create one or more server nodes and
client nodes. On creation, both resources have a corresponding `null_resource` with a
`remote_exec` provisioner.

This provisioners are triggered by changes in their respective Ansible playbooks,
`ansible/server.yml` and `ansible/client.yml`, and runs them.

### Commands
To start the deployment, ensure all variables are populated in `terraform.tfvars`.

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
