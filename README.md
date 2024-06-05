# Import ESXI-VMs via CLI

1) Vorab : vmware-tools deinstallieren
2) Danach VMware-VM shutdown.

3) via OVFtool nach Proxmox kopieren( muss ggf. nach installiert werden )
   
  `$ ovftool vi://VMUSER:VMPASS@esxihost/VM /some/directory/VM`

5) import OVF: 
  format : 'qm importovf <vmid> <manifest> <storage>'
  $ qm importovf 100 /XXX/testvm/testvm.ovf local-lvm

6) KVM-Umkonfigurieren :
```   
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
  
  # add drivers-disk via IDE: ( Storage - Pfad anpassen ) 
  qm set $1 --ide3 local:iso/virtio-win.iso,media=cdrom
  
  # add small scsi-disk so that drivers are installed successfully ( Storage - Pfad anpassen ) 
  qm set $1 --virtio15 local:1,size=1G
```

6) Windows booten, virtio-treiber installieren und Proxmox-VM herunterfahren.

7) cleanup/frinal VM-Config .
```
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
```
