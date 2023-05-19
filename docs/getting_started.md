This document assumes all nodes are running on Proxmox as Debian 11 VMs. Please
fork the project and make the necessary configuration changes should you choose
to run the cluster on LXCs or an alternative distro.

## Prerequisites

See [Prerequisites](prerequisites.md) for the full requirements.

## Provisioning with Terraform

1. Navigate to `terraform/cluster`.
2. Populate the necessary variables in `terraform.tfvars`:

    ```hcl
    proxmox_ip       = "https://${PVE_IP}:8006/api2/json"
    proxmox_user     = "user@pam"
    proxmox_password = "password"

    template_name = "base-template-name"
    server_vmid      = [110]
    client_vmid      = [111]
    server_ip_address = ["10.10.10.110/24"]
    client_ip_address = ["10.10.10.111/24"]
    ip_gateway        = "10.10.10.1"

    ssh_user             = "debian"
    ssh_private_key_file = "/path/to/ssh/private/key"
    ssh_public_key_file  = "/path/to/ssh/public/key"
    ```

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

!!! note
    For more information, refer to the [Terraform configuration for Proxmox](terraform/proxmox.md).

## Configuration with Ansible

1. Navigate to `ansible`.
2. Populate the inventory file in `inventory/hosts.yml`:

    ```yml
    all:
      children:
        cluster:
          children:
            server:
              hosts:
                10.10.10.110:
            client:
              hosts:
                10.10.10.111:
            prod:
              hosts:
                10.10.10.110:
                10.10.10.111:
    ```

3. Populate and check the `group_vars` file in
   `inventory/group_vars/{prod,server,client}.yml`.
   ```bash
    $ ansible-inventory --graph
   ```
4. Run the playbook:

    ```bash
    $ ansible-playbook main.yml
    ```

This will configure and start Vault, Consul and Nomad in both nodes with mTLS
and gossip encryption.
