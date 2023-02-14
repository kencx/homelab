## Import Cloud Image

1. Download the latest [Debian](https://cloud.debian.org/images/cloud/) cloud image

        $ wget https://cloud.debian.org/images/cloud/bullseye/20230124-1270/debian11-generic-amd64-20230124-1270.qcow2

    >Alternatively, we can create our own custom cloud image from scratch. Simply
    >ensure `cloud-init` is installed.

2. Create a Proxmox VM from the above cloud image:

        $ qm create 9000 -name 'debian-cloudinit' -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1

        # Import disk image to Proxmox storage
        $ qm importdisk 9000 [path/to/image] local-lvm [-format qcow2/raw]

        # Attach the disk via SCSI
        $ qm set 9000 -scsihw virtio-scsi-pci -scsi0 local-lvm:vm-9000-disk-0

        # Set bootdisk to the imported disk
        $ qm set 9000 -boot c -bootdisk scsi0

        # Enable Qemu agent
        $ qm set 9000 -agent 1

        # Allow hotplugging of network, USB and disks
        $ qm set 9000 -hotplug disk,network,usb

        # Add a single vCPU (for now)
        $ qm set 9000 -vcpus 1

        # Add a serial output and video ouput
        $ qm set 9000 -serial0 socket -vga serial0

        # Resize the primary boot disk (otherwise it will be around 2G by default)
        $ qm resize 9000 scsi0 +3G

3. Attach an additional CD-ROM for cloud-init support:

        $ qm set 9000 -ide2 local-lvm:cloudinit

4. Finally, convert the VM into a template:

        $ qm template 9000

The result is a template of the cloud image that other VMs can build on. It
should appear in the list of templates in the Proxmox GUI.

## References
- [Proxmox Wiki - cloud-init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
