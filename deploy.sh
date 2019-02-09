#!/usr/bin/env bash

cd /root

# Enable no-sybscription Proxmox repo
cat <<END > /etc/apt/sources.list.d/pve-enterprise.list
#deb https://enterprise.proxmox.com/debian/pve stretch pve-enterprise
END

cat <<END > /etc/apt/sources.list.d/pve-no-sybscription.list
deb http://ftp.debian.org/debian stretch main contrib

# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve stretch pve-no-subscription

# security updates
deb http://security.debian.org stretch/updates main contrib
END

# Upgrade packages
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

# Install required packages
apt-get install -y screen git curl unzip vim

# Install GOLANG
curl -O https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz
tar xvzf go1.10.2.linux-amd64.tar.gz
chown -R root:root ./go
mv go /usr/local
rm -f go1.10.2.linux-amd64.tar.gz

cat <<EOF >> ~/.profile
export PATH=\$PATH:/usr/local/go/bin:~/go/bin
EOF

# Load profile to enable GOLANG
source .profile

# Install terraform
curl -O https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
unzip terraform_0.11.11_linux_amd64.zip
mv terraform /usr/local/bin/
rm -f terraform_0.11.11_linux_amd64.zip
terraform version

# Install proxmox / terraform dependencies
go get github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
go get github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
go get github.com/Telmate/proxmox-api-go
go install github.com/Telmate/proxmox-api-go

