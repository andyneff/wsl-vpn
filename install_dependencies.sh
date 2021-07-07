#!/usr/bin/env bash

source common.env

# Determine dependencies
dependencies=(socat)
deb_install=(socat)

# apt-get install socat --print-uris -qq
# 10
debian_10_files=(http://deb.debian.org/debian/pool/main/t/tcp-wrappers/libwrap0_7.6.q-28_amd64.deb
                 http://deb.debian.org/debian/pool/main/s/socat/socat_1.7.3.2-2_amd64.deb
                 http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1d-0+deb10u6_amd64.deb)

# 9 Still in LTS
debian_9_files=(http://deb.debian.org/debian/pool/main/t/tcp-wrappers/libwrap0_7.6.q-26_amd64.deb
                http://deb.debian.org/debian/pool/main/t/tcp-wrappers/tcpd_7.6.q-26_amd64.deb
                http://deb.debian.org/debian/pool/main/s/socat/socat_1.7.3.1-2+deb9u1_amd64.deb
                http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.0l-1~deb9u3_amd64.deb)

# 8 Still in ELTS
debian_8_files=(http://deb.debian.org/debian/pool/main/t/tcp-wrappers/libwrap0_7.6.q-25_amd64.deb
                http://deb.debian.org/debian/pool/main/t/tcp-wrappers/tcpd_7.6.q-25_amd64.deb
                http://deb.debian.org/debian/pool/main/s/socat/socat_1.7.2.4-2_amd64.deb
                http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb)

# dnf download --url socat
# http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/socat-1.7.3.3-2.el8.x86_64.rpm
# http://mirror.centos.org/centos/7/os/x86_64/Packages/socat-1.7.3.2-2.el7.x86_64.rpm

if [ "${no_docker-0}" = "0" ]; then
  dependencies+=(unzip isoinfo)
  deb_install=(unzip genisoimage)
fi

for cmd in "${dependencies[@]}"; do
  if ! command -v "${cmd}" &> /dev/null; then
    if [ "${on_vpn-0}" = "0" ]; then
      if command -v apt &> /dev/null; then
        apt update
        apt install -y "${deb_install[@]}"
        break
      elif command -v yum &> /dev/null; then
        # Tested on Centos/rhell 7/8, and Fedora, same names
        yum install -y "${deb_install[@]}"
        break
      # elif command -v apk &> /dev/null; then
      # elif command -v yast2 &> /dev/null; then
      #   ...
      else
        echo "Todo: program other package managers" &> /dev/null
        exit 3
      fi
    else
      echo "Warning: You have enabled \"on VPN\" mode and need (${dependendies[*]})" >&2
      echo "installed. You may have no other option if you are \"Always on VPN\"," >&2
      echo "but be warned this mode is fragile and may now work work with your" >&2
      echo "WSL distro. If this does not work, you can always try and convert" >&2
      echo "your WSL 2 distro to WSL 1 using the \"wsl --set-version\"" >&2
      echo "command, and then install (${dependendies[*]}), and then convert" >&2
      echo "it back to WSL 2" >&2
      
      # "Modern" Linuxes have /etc/os-release
      source /etc/os-release || :

      case "${ID-Unknown OS}" in
        debian)
          ;;
        fedora)

          ;;
        centos|rhel)
          # ${VERSION_ID} Might be 8.3
          ;;
        *)
          ;;
      esac
    fi
  fi
done