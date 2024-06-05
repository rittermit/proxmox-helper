#!/bin/bash
if [ "x$1" == "x" ]; then
        echo "Missing VM-Nr"
        exit 1
fi

# change BIOS to UEFI
qm set $1 --bios ovmf
# change OS to Win2016
qm set $1 --ostype win10

# reattach disk0 to use sata
sed -i 's/scsi0:/sata0:/' /etc/pve/qemu-server/$1.conf
# boot from SATA
qm set $1 --boot order=sata0

# add  EFI-Disk
qm set $1 --efidisk0 zfs:1

# add drivers-disk via IDE:
qm set $1 --ide3 local:iso/virtio-win.iso,media=cdrom

# add small scsi-disk so that drivers are installed successfully
qm set $1 --virtio15 zfs:1,size=1G
