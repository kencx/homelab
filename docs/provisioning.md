
## Golden Images with Packer

Packer's
[Proxmox](https://developer.hashicorp.com/packer/plugins/builders/proxmox)
builder is used to build a base Proxmox VM template from an existing Debian 11
cloud image. It clones an existing template and uses Ansible to execute common
provisioning tasks such as installing common packages and security hardening. On
completion, the VM is converted into a Proxmox template.

!!! note
    Packer can also build images from an ISO with `proxmox-iso`. This is currently a
    work-in-progress.

## Provisioning with Terraform

Terraform provisions Proxmox VMs from existing golden images with the
[telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
provider. It utilizes cloud-init to set up the host's hostname, user and SSH
access keys.

## Post-provisioning with Ansible

Ansible configures and starts the Hashicorp software necessary to run a
functional cluster. The Ansible playbooks use modular and independent roles to
set up hosts as a server or client node.

On server nodes,

1. Vault is initialized with TLS encryption. After unsealing, first-time
   setup is performed with the root token and Terraform.
2. Consul-template is configured with limited access to Vault via Vault-agent.
3. Nomad and Consul are configured with mTLS encryption in server mode.
4. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).

On client nodes, after the server nodes are up,

1. Consul-template is configured with limited access to the remote Vault server
   via Vault-agent.
2. Nomad and Consul are configured with mTLS encryption in client mode.
3. A smoke test is performed with [Goss](https://github.com/aelsabbahy/goss).
