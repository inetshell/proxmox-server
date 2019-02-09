#!/usr/bin/env bash
# https://pve.proxmox.com/pve-docs/qm.1.html

# download centos images
cd /var/lib/vz/template/qemu/
wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
tar xvzf CentOS-7-x86_64-GenericCloud.raw.tar.gz

# create a new VM
qm create 9000 --memory 1024 --net0 virtio,bridge=vmbr0

# import the downloaded disk to local-lvm storage
qm importdisk 9000 CentOS-7-x86_64-GenericCloud.raw local-lvm

# finally attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-1

# Add cloudinit drive
qm set 9000 --ide2 local-lvm:cloudinit

curl -O https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz

qm create 900 --net0 virtio,bridge=vmbr0 --name vm600 --serial0 socket \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --ostype l26