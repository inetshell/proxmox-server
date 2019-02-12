#!/usr/bin/env bash
# For mode information, go to https://pve.proxmox.com/pve-docs/qm.1.html

# VM settings
VMID="9000"
VMNAME="centos7-template"
VMMEMORY="1024"
DISKSIZE="32G"
OSTYPE="l26"

echo "=== checking if VM ${VMID} exists ==="
qm status ${VMID} > /dev/null 2>&1
RETURN=$?
if [[ ${RETURN} -eq 0 ]]; then
  echo "The VM ${VMID} already exists, please remove it before continue"
  exit 1
fi

echo "=== creating temp directory ==="
WORKDIR=$(mktemp -d)

echo "=== downloading centos iso ==="
cd ${WORKDIR}
wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
tar xvzf CentOS-7-x86_64-GenericCloud.raw.tar.gz

echo "=== creating VM ==="
qm create ${VMID} --memory ${VMMEMORY} --ostype ${OSTYPE} --name "${VMNAME}"
qm set ${VMID} --scsihw virtio-scsi-pci --virtio0 local-lvm:vm-${VMID}-disk-0
qm set ${VMID} --bootdisk virtio0
qm set ${VMID} --agent=1

echo "--- importing disk ---"
qm importdisk ${VMID} CentOS-7-x86_64-GenericCloud-*.raw local-lvm
qm resize ${VMID} virtio0 $DISKSIZE

echo "--- adding network interfaces ---"
qm set ${VMID} --net0 virtio,bridge=vmbr0

echo "--- attaching cloudinit drive ---"
qm set ${VMID} --ide2 local-lvm:cloudinit

echo "--- converting into template ---"
qm set ${VMID} --template=1

echo "---removing temp files ---"
if [[ ! -z ${WORKDIR} ]]; then
  cd /tmp
  rm -rf ${WORKDIR}
fi

echo "=== show VM config ==="
qm config ${VMID}

echo " === DONE ==="
exit 0
