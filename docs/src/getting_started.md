# Getting Started

This documents provides an overview for provisioning and installing the cluster.

>**Note**: It is assumed that all nodes are running on Proxmox as Debian 11 VMs.
>Please fork the project and make the necessary configuration changes should you
>choose to run the cluster with LXCs or an alternative distro.

## Prerequisites

See [Prerequisites](prerequisites.md) for the full requirements.

>**Note**: Use the `bin/generate-vars` script to quickly generate variable files
>in `packer` and `terraform` subdirectories.

## Creating a VM template

There are two methods to create a VM template:

- From an [ISO file](./images/packer.md#proxmox-iso) (WIP)
- From an [existing cloud image](./images/packer.md#proxmox-clone) (recommended)

We will be building the template from an existing cloud image.

>**Note**: See [Cloud Image](images/cloud_image.md) for how to import an
>existing cloud image into Proxmox.

1. Navigate to `packer/base-clone`.
2. Populate the necessary variables in `auto.pkrvars.hcl`:

```hcl
proxmox_url      = "https://${PVE_IP}:8006/api2/json"
proxmox_username = "user@pam"
proxmox_password = "password"

clone_vm = "cloud-image-name"
vm_name  = "base-template"
vm_id    = 5000

ssh_username = "debian"
ssh_public_key_path = "/path/to/public/key"
ssh_private_key_path = "/path/to/private/key"
```

3. Build the image:

```bash
$ packer validate -var-file="auto.pkrvars.hcl" .
$ packer build -var-file="auto.pkrvars.hcl" .
```

Packer will create a new base image that has common configuration and
software installed (eg. Docker). For more information, refer to
[Packer](./images/packer.md#proxmox-clone).

## Provisioning with Terraform

1. Navigate to `terraform/cluster`.
2. Populate the necessary variables in `terraform.tfvars`:

```hcl
proxmox_ip        = "https://${PVE_IP}:8006/api2/json"
proxmox_api_token = "${API_TOKEN}"

template_id = 5000
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

ssh_user             = "debian"
ssh_private_key_file = "/path/to/ssh/private/key"
ssh_public_key_file  = "/path/to/ssh/public/key"
```

>**Note**: To create a Proxmox API token, see [Access
>Management](./terraform/proxmox.md#access-management).

>**Note**: Any template to be cloned by Terraform must have `cloud-init` and
>`qemu-guest-agent` installed.

3. Provision the cluster:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

The above configuration will provision two VM nodes in Proxmox:

```
Server node: VMID 110 at 10.10.10.110
Client node: VMID 111 at 10.10.10.111
```

An Ansible inventory file `tf_ansible_inventory` should be generated in the same
directory with the given VM IPs in the `server` and `client` groups.

For more information, refer to the [Terraform configuration for
Proxmox](terraform/proxmox.md).

## Configuration with Ansible

1. Navigate to `ansible`.
2. Ensure that the Terraform-generated Ansible inventory file is being read:

```bash
$ ansible-inventory --graph
```

3. Populate and check the `group_vars` file in
   `inventory/group_vars/{prod,server,client}.yml`

```bash
$ ansible-inventory --graph --vars
```

4. Run the playbook:

```bash
$ ansible-playbook main.yml
```

This will configure and start Vault, Consul and Nomad in both nodes with mTLS
and gossip encryption.
