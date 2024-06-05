#!/bin/bash
if [ "x$1" == "x" ]; then
        echo "Missing VMnr"
        exit 1
fi

# remove tmp-scsi-disk
qm set $1 --delete virtio15

# remove driver-DVD
qm set $1 --delete ide3

# reattach disk0 as SCSI
sed -i 's/sata0:/virtio0:/' /etc/pve/qemu-server/$1.conf
# bootorder to SCSI
qm set $1 --boot order=virtio0

# set SCSI-Controller "virtio"
qm set $1 --scsihw virtio-scsi-pci
# enable qemu-agent
qm set $1 --agent 1
