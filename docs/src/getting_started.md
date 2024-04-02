# Getting Started

Our goal is to provision a Nomad, Consul and Vault cluster with one server node
and one client node. The basic provisioning flow is as follows:

1. Packer creates base Proxmox VM templates from cloud images and ISOs
2. Terraform provisions cluster nodes by cloning existing VM templates
3. Ansible installs and configures Vault, Consul, Nomad on cluster nodes

### Assumptions

The following assumptions are made in this guide:

- All [prerequisites](./prerequisites.md) are fulfilled
- The cluster is provisioned on a Proxmox server
- All nodes are running Debian 11 virtual machines (not LXCs)

Please make the necessary changes if there are any deviations from the above.

## Creating a VM template

The Proxmox builder plugin is used to create a new VM template. It supports two
different builders:

- `proxmox-clone` - From an [existing VM template](./images/packer.md#proxmox-clone) (recommended)
- `proxmox-iso` - From an [ISO file](./images/packer.md#proxmox-iso) (incomplete)

We will be using the first builder. If you have an existing template to
provision, you may [skip to the next section](#provisioning-with-terraform).
Otherwise, assuming that we are lacking an existing, clean VM template, we will
import a cloud image and turn it into a new template.

>**Note**: It is important that the existing template [must
>have](https://pve.proxmox.com/wiki/Cloud-Init_Support#_preparing_cloud_init_templates):
>
>    - An attached cloud-init drive for the builder to add the SSH communicator
>      configuration
>    - cloud-init installed
>    - qemu-guest-agent installed

1. (Optional) Run the `bin/import-cloud-image` [script](./images/cloud_image.html#script) to import a new cloud image:

```bash
$ import-cloud-image [URL]
```

2. Navigate to `packer/base-clone`

>**Tip**: Use the `bin/generate-vars` script to quickly generate variable files
>in `packer` and `terraform` subdirectories.

3. Populate the necessary variables in `auto.pkrvars.hcl`:

```hcl
proxmox_url      = "https://<PVE_IP>:8006/api2/json"
proxmox_username = "<user>@pam"
proxmox_password = "<password>"

clone_vm = "<cloud-image-name>"
vm_name  = "<new-template-name>"
vm_id    = 5000

ssh_username = "debian"
ssh_public_key_path = "/path/to/public/key"
ssh_private_key_path = "/path/to/private/key"
```

4. Build the image:

```bash
$ packer validate -var-file="auto.pkrvars.hcl" .
$ packer build -var-file="auto.pkrvars.hcl" .
```

Packer will create a new base image and use the Ansible post-provisioner to
install and configure software (eg. Docker, Nomad, Consul and Vault). For more
details, see [Packer](./images/packer.md#proxmox-clone).

## Provisioning with Terraform

We are using the
[bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
provider to provision virtual machines from our Packer templates.

1. Navigate to `terraform/cluster`
2. Populate the necessary variables in `terraform.tfvars`:

```hcl
proxmox_ip        = "https://<PVE_IP>:8006/api2/json"
proxmox_api_token = "<API_TOKEN>"

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

<!-- >**Note**: To create a Proxmox API token, see [Access -->
<!-- >Management](./terraform/proxmox.md#access-management). -->

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

For more details, refer to the [Terraform configuration for
Proxmox](terraform/proxmox.md).

## Configuration with Ansible

At this stage, there should be one server node and one client node running on
Proxmox that is reachable by SSH. These nodes should have Nomad, Consul and
Vault installed. We will proceed to use Ansible (and Terraform) to configure
Vault, Consul and Nomad (in that order) into a working cluster.

1. Navigate to `ansible`
2. Ensure that the Terraform-generated Ansible inventory file is being read:

```bash
$ ansible-inventory --graph
```

3. Populate and check the `group_vars` files in
   `inventory/group_vars/{prod,server,client}.yml`

```bash
$ ansible-inventory --graph --vars
```

>**Note**: The `nfs_share_mounts` variable in `inventory/group_vars/client.yml`
>should be modified or removed if not required

4. Run the playbook:

```bash
$ ansible-playbook main.yml
```

The playbook will perform the following idempotently:

1. Create a root and intermediate CA for Vault
2. Configure Vault to use new CA
3. Initialize Vault roles, authentication and PKI with Terraform with
   [configuration](./terraform/vault.md) in `terraform/vault`
4. Configure Vault-agent and consul-template in server node
5. Configure Consul and Nomad in server node. These roles depend on Vault being
   successfully configured and started as they require Vault to generate a
   gossip key and TLS certificates
6. Repeat 4-5 for client node

### Note on Data Loss

When re-running the playbook on the same server, Vault will not be
re-initialized. However, if the playbook is run on a separate server (eg. for
testing on a dev cluster), the Vault role will permanently delete any
existing state in the `terraform/vault` subdirectory if a different
`vault_terraform_workspace` is not provided. This WILL result in permanent data
loss and care should be taken when running the role (and playbook) on multiple
clusters or servers.
