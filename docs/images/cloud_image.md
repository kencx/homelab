
Unlike ISOs and LXC templates, Proxmox's API lacks support for uploading cloud
images directly from a given URL (see
[here](https://bugzilla.proxmox.com/show_bug.cgi?id=4141) and
[here](https://forum.proxmox.com/threads/new-vm-from-cloud-init-image-via-api.111091/)).
Instead, they must be manually downloaded and converted into a VM template for
use.

We can also choose to create our own custom cloud image from scratch
with an [ISO](./packer.md#proxmox-iso) and install `cloud-init`.

## Manual Upload

1. Download any cloud image:

        $ wget https://cloud.debian.org/images/cloud/bullseye/20230124-1270/debian11-generic-amd64-20230124-1270.qcow2

2. Create a Proxmox VM from the downloaded image:

        $ qm create 9000 \
            --name "debian-11-amd64" \
            --net0 "virtio,bridge=vmbr0" \
            --serial0 socket \
            --vga serial0 \
            --scsihw virtio-scsi-pci \
            --scsi0 "local:0,import-from=/path/to/image" \
            --bootdisk scsi0 \
            --boot "order=scsi0" \
            --ide1 "local:cloudinit" \
            --ostype l26 \
            --cores 1 \
            --sockets 1 \
            --memory 512 \
            --agent 1

3. Resize the new VM (if necessary):

        $ qm resize 9000 scsi0 5G

4. Convert the VM into a template:

        $ qm template 9000

## Script

A full script of the steps above can be found at
[bin/import-cloud-image](https://github.com/kencx/homelab/blob/master/bin/import-cloud-image).

```bash
$ import-cloud-image --help
Usage: import-cloud-image [--debug|--force] [URL] [FILENAME]
```

## Usage

The new template can be cloned and used directly by
[Terraform](../terraform/proxmox.md).

However, if we are provisioning VMs with Terraform, `qemu-guest-agent` must be
installed in the template. As such, it is recommended to create a further
bootstrapped template with [Packer and Ansible](./packer.md).

!!! warning
    If `qemu-guest-agent` is not installed or `agent=1` is not set, Terraform
    will
    [timeout](https://github.com/Telmate/terraform-provider-proxmox/issues/325)
    when trying to clone and provision the VM.

## References
- [Proxmox Wiki - cloud-init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
