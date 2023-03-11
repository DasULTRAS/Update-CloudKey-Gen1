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

if [ `cat /etc/apt/sources.list | egrep "^deb|^#" | wc -l` -le 4 ]; then
    echo "# stretch" >> /etc/apt/sources.list
fi

lsb_release -a
DEBIAN_FRONTEND=noninteractive
state="`tail -1 /etc/apt/sources.list | cut -d' ' -f2 | egrep -v 'http'`"

stretch () {
tar -zcvf ~/sources.tgz /etc/apt/sources.list.d/
rm -rfv /etc/apt/sources.list.d/*
dpkg-reconfigure dash #Select NO Here
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C 648ACFD622F3D138
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
apt -y purge freeradius freeradius-common freeradius-ldap freeradius-utils bind9-host
apt -y purge libldap-common liblocale-gettext-perl
apt -y purge aufs-tools initramfs-tools
apt -y purge busybox*
apt update
apt -y upgrade
apt -y dist-upgrade
apt-get -y autoremove
echo "# buster" >> /etc/apt/sources.list
reboot
}

buster () {
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ buster main contrib non-free
deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb http://deb.debian.org/debian/ buster-backports main
deb http://security.debian.org/ buster/updates main contrib non-free
EOF
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
echo "# bullseye" >> /etc/apt/sources.list
reboot
}

bullseye () {
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian stable main contrib non-free
deb-src http://deb.debian.org/debian stable main contrib non-free
deb http://security.debian.org/debian-security stable-security main contrib non-free
deb-src http://security.debian.org/debian-security stable-security main contrib non-free
EOF
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
reboot
}

if [ -z $state ]; then
        echo "Latest tested version installed..."
else
        echo "Starting with $state"
        $state
fi
