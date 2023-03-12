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
sudo tar -zcvf ~/sources.tgz /etc/apt/sources.list.d/
sudo rm -rfv /etc/apt/sources.list.d/*
sudo dpkg-reconfigure dash #Select NO Here
# Add missing not privileged User for installation
sudo adduser --system --force-badname --home /nonexistent --no-create-home --shell /bin/false --group _apt
sudo passwd -l _apt
sudo chown -R _apt /var/cache/apt/
# Add missing keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C 648ACFD622F3D138 112695A0E562B32A 0E98404D386FA1D9
sudo bash -c 'cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://deb.debian.org/debian/ stretch-backports main
deb http://security.debian.org/ stretch/updates main contrib non-free
EOF'
sudo apt update
sudo apt -y purge mongodb-clients mongodb-server
sudo apt -y purge ubnt-archive-keyring ubnt-unifi-setup unifi
sudo apt -y purge rfkill bt-proxy bluez openjdk-8-jre-headless:armhf
sudo rm -rf /etc/bt-proxy
sudo apt -y purge freeradius freeradius-common freeradius-ldap freeradius-utils bind9-host
sudo apt -y purge libldap-common liblocale-gettext-perl
sudo apt -y purge aufs-tools initramfs-tools
sudo rm -rf /var/lib/initramfs-tools
sudo apt -y purge exim4-daemon-light exim4-config exim4-base
sudo rm -rf /var/lib/exim4
sudo apt -y purge busybox*
sudo apt-get -y autoremove
sudo apt update
sudo apt -y upgrade
sudo rm -rf /var/run/avahi-daemon
sudo apt -y dist-upgrade
sudo apt -y autoremove
echo "# buster" >> /etc/apt/sources.list
echo "REBOOT SYSTEM"
}

buster () {
sudo bash -c 'cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
EOF'
## Remove unknown group 'Debian-exim' in statoverride file
# Check if the statoverride file exists
sudo bash -c 'if [[ ! -f "/var/lib/dpkg/statoverride" ]]; then
  echo "Statoverride file not found"
fi'
# Check if the line exists in the statoverride file
sudo bash -c 'if [[ ! $(grep "Debian-exim" /var/lib/dpkg/statoverride) ]]; then
  echo "Debian-exim not found in statoverride file"
fi'
# Remove the line from the statoverride file
sudo bash -c 'sed -i '/Debian-exim/d' /var/lib/dpkg/statoverride'
# Print success message
echo "Line removed from statoverride file"
# Updates
sudo apt update
sudo apt -y upgrade
sudo apt -y dist-upgrade
sudo apt -y autoremove
# init next installation
echo "# bullseye" >> /etc/apt/sources.list
echo "REBOOT SYSTEM"
}

bullseye () {
sudo bash -c 'cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian stable main contrib non-free
deb-src http://deb.debian.org/debian stable main contrib non-free
deb http://security.debian.org/debian-security stable-security main contrib non-free
deb-src http://security.debian.org/debian-security stable-security main contrib non-free
EOF'
# Updates
sudo apt update
sudo apt -y upgrade
sudo apt -y dist-upgrade
sudo apt -y autoremove
echo "REBOOT SYSTEM"
}

if [ -z $state ]; then
        echo "Latest tested version installed..."
else
        echo "Starting with $state"
        $state
fi

exit 0
