terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.36.0"
    }
  }
}

# This configuration requires root credentials for access management for future
# Terraform runs. It creates a "terraform" user for management of VMs and is to be used
# with an API token. The API token must be manually created in the PVE web console.

provider "proxmox" {
  endpoint = var.proxmox_ip
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true
}

data "proxmox_virtual_environment_role" "vm_admin" {
  role_id = "PVEVMAdmin"
}

data "proxmox_virtual_environment_role" "datastore_user" {
  role_id = "PVEDatastoreUser"
}

resource "proxmox_virtual_environment_group" "tf" {
  group_id = "Terraform"
  comment  = "Terraform Providers"

  acl {
    path      = "/vms"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.vm_admin.role_id
  }

  acl {
    path      = "/vms"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.datastore_user.role_id
  }

  acl {
    path      = "/storage"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.vm_admin.role_id
  }

  acl {
    path      = "/storage"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.datastore_user.role_id
  }
}

resource "proxmox_virtual_environment_user" "tf" {
  user_id = "terraform@pam"
  comment = "Managed by Terraform BPG Provider"
  groups  = [proxmox_virtual_environment_group.tf.group_id]
  enabled = true
}
