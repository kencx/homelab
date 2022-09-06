#!/bin/bash

# This script templates a base cloud-init image for use by Packer

IMG_NAME=""
TEMPLATE_NAME="debian11-cloud"
VMID="9001"
MEM="512"
NET_BRIDGE="vmbr1"
DISK_SIZE="5G"
DISK_STORE="volumes"

qm create "$VMID" --name "$TEMPLATE_NAME" --memory "$MEM" --net0 virtio,bridge="$NET_BRIDGE"
qm importdisk "$VMID" "$IMG_NAME" "$DISK_STORE"

# attach via scsi
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $DISK_STORE:vm-$VMID-disk-0

# set bootdisk to imported disk
qm set $VMID --boot c --bootdisk scsi0

# add cloudinit drive
qm set $VMID --ide2 $DISK_STORE:cloudinit

# add serial output
qm set $VMID --serial0 socket --vga serial0

qm resize $VMID scsi0 $DISK_SIZE
qm template $VMID
