#!/bin/bash

trap cleanup EXIT
function cleanup {
	rm -f upgrade.list
}

trap ctrl_c INT
function ctrl_c() {
	rm -f upgrade.list
	ubnt-systool reset2defaults
}

if [ `cat /etc/apt/sources.list | egrep "^deb|^#" | wc -l` -le 1 ]; then
    echo "# stretch" >> /etc/apt/sources.list
fi

lsb_release -a
DEBIAN_FRONTEND=noninteractive
state="`tail -1 /etc/apt/sources.list | cut -d' ' -f2 | egrep -v 'http'`"

stretch () {
tar -zcvf ~/sources.tgz /etc/apt/sources.list.d/
rm -rfv /etc/apt/sources.list.d/*
dpkg-reconfigure dash #Select NO Here
# Add missing not privileged User for installation
adduser --system --force-badname --home /nonexistent --no-create-home --shell /bin/false --group _apt
passwd -l _apt
# Add missing keys
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C 648ACFD622F3D138 112695A0E562B32A 0E98404D386FA1D9
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://deb.debian.org/debian/ stretch-backports main
deb http://security.debian.org/ stretch/updates main contrib non-free
EOF
apt update
apt -y purge mongodb-clients mongodb-server
apt -y purge ubnt-archive-keyring ubnt-unifi-setup unifi
apt -y purge rfkill bt-proxy bluez openjdk-8-jre-headless:armhf
rm -rf /etc/bt-proxy
apt -y purge freeradius freeradius-common freeradius-ldap freeradius-utils bind9-host
apt -y purge libldap-common liblocale-gettext-perl
apt -y purge aufs-tools initramfs-tools
rm -rf /var/lib/initramfs-tools
apt -y purge exim4-base exim4-config exim4-daemon-light
rm -rf /var/lib/exim4
apt -y purge busybox*
apt-get -y autoremove
apt update
apt -y upgrade
rm -rf /var/run/avahi-daemon
apt -y dist-upgrade
apt-get -y autoremove
echo "# buster" >> /etc/apt/sources.list
echo "REBOOT SYSTEM"
}

buster () {
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
EOF
## Remove unknown group 'Debian-exim' in statoverride file
# Check if the statoverride file exists
if [[ ! -f "/var/lib/dpkg/statoverride" ]]; then
  echo "Statoverride file not found"
  exit 1
fi
# Check if the line exists in the statoverride file
if [[ ! $(grep "Debian-exim" /var/lib/dpkg/statoverride) ]]; then
  echo "Line not found in statoverride file"
  exit 1
fi
# Remove the line from the statoverride file
sudo sed -i '/Debian-exim/d' /var/lib/dpkg/statoverride
# Print success message
echo "Line removed from statoverride file"
# Updates
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
echo "REBOOT SYSTEM"
}

if [ -z $state ]; then
        echo "Latest tested version installed..."
else
        echo "Starting with $state"
        $state
fi
