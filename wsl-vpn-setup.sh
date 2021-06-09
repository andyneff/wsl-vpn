#!/usr/bin/env bash

set -eu

if [ ${EUID:-$(id -u)} -ne 0 ] || [ -z "${SUDO_USER-}" ]; then
    echo "You need to run this as sudo"
    exit 1
fi

# This function check if the file exist then only append the line once
function write_to_file() {
    if [ -e "$2" ]; then
        grep -qFs "$1" "$2" || echo "$1" | tee -a "$2"
    fi
}


DOCKER_WSL="/mnt/c/Program Files/Docker/Docker/resources"

for cmd in socat unzip isoinfo wget p7zip; do
    if ! command -v "${cmd}" &> /dev/nul; then
        # Warning: Specific to debian/ubuntu
        apt update
        apt install -y socat unzip p7zip genisoimage wget
        break
    fi
done

cp ./wsl_vpn_start.sh /usr/bin/
chmod +x /usr/bin/wsl_vpn_start.sh
cp ./wsl-vpnkit.service /etc/init.d/wsl-vpnkit
chmod +x /etc/init.d/wsl-vpnkit
chown root:root /etc/init.d/wsl-vpnkit

# Dangerous stuff
touch /etc/sudoers.d/wsl-vpnkit
write_to_file "${SUDO_USER} ALL=(ALL) NOPASSWD: /usr/sbin/service wsl-vpnkit *" /etc/sudoers.d/wsl-vpnkit
chown root:root /etc/sudoers.d/wsl-vpnkit

cd ~
mkdir -p /mnt/c/bin
cp "${DOCKER_WSL}/vpnkit.exe" /mnt/c/bin/wsl-vpnkit.exe

isoinfo -i "${DOCKER_WSL}/wsl/docker-for-wsl.iso" -R -x /containers/services/vpnkit-tap-vsockd/lower/sbin/vpnkit-tap-vsockd > ./vpnkit-tap-vsockd
mv vpnkit-tap-vsockd /sbin/vpnkit-tap-vsockd
chmod +x /sbin/vpnkit-tap-vsockd
chown root:root /sbin/vpnkit-tap-vsockd

wget https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip
unzip npiperelay_windows_amd64.zip npiperelay.exe
rm npiperelay_windows_amd64.zip
mv npiperelay.exe /mnt/c/bin/



write_to_file "service wsl-vpnkit start"  /etc/profile
write_to_file "service wsl-vpnkit start"  /etc/zsh/zprofile


