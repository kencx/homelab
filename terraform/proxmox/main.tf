terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.36.0"
    }
  }
}

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

data "proxmox_virtual_environment_role" "datastore_admin" {
  role_id = "PVEDatastoreAdmin"
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
    path      = "/storage"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.datastore_user.role_id
  }

  # upload vm ISOs
  acl {
    path      = "/storage/local"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.datastore_admin.role_id
  }
}

resource "proxmox_virtual_environment_user" "tf" {
  user_id = "terraform@pam"
  comment = "Managed by Terraform BPG Provider"
  groups  = [proxmox_virtual_environment_group.tf.group_id]
  enabled = true
}

resource "proxmox_virtual_environment_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path      = "https://cloud.debian.org/images/cloud/bullseye/20231013-1532/debian-11-generic-amd64-20231013-1532.qcow2"
    file_name = "debian-11-generic-amd64-20231013-1532.img"
  }

  lifecycle {
    ignore_changes = [
      source_file
    ]
  }
}
