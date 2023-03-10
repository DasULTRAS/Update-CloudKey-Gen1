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
    echo "# debian" >> /etc/apt/sources.list
fi

DEBIAN_FRONTEND=noninteractive
state="`tail -1 /etc/apt/sources.list | cut -d' ' -f2 | egrep -v 'http'`"

debian () {
tar -zcvf ~/sources.tgz /etc/apt/sources.list.d/
rm -rfv /etc/apt/sources.list.d/*
dpkg-reconfigure dash #Select NO Here
lsb_release -a
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://deb.debian.org/debian/ stretch-backports main
deb http://security.debian.org/ stretch/updates main contrib non-free
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C 648ACFD622F3D138
apt update
apt -y purge mongodb-clients mongodb-server
apt -y purge ubnt-archive-keyring ubnt-unifi-setup unifi
apt -y purge rfkill bt-proxy bluez openjdk-8-jre-headless:armhf
apt -y purge freeradius freeradius-common freeradius-ldap freeradius-utils bind9-host
apt -y purge libldap-common liblocale-gettext-perl
apt -y purge busybox*
apt-get -y autoremove
echo "# xenial" >> /etc/apt/sources.list
reboot
}

xenial () {
lsb_release -a
cat << EOF > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports xenial main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports xenial-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports xenial-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted universe multiverse
EOF
apt update
apt -y upgrade
apt -y full-upgrade
apt -y autoremove
echo "# bionic" >> /etc/apt/sources.list
reboot
}

bionic () {
lsb_release -a
cat << EOF > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports bionic main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports bionic-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports bionic-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports bionic-security main restricted universe multiverse
EOF
apt update
apt -y upgrade
apt -y full-upgrade
apt -y autoremove
echo "# focal" >> /etc/apt/sources.list
reboot
}

focal () {
lsb_release -a
cat << EOF > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse
EOF
apt update
apt -y install libcrypt1 libcryptsetup12 libhcrypto4-heimdal libgcrypt20 libk5crypto3
apt -y upgrade
apt -y full-upgrade
apt -y autoremove
echo "# clean" >> /etc/apt/sources.list
reboot
sleep 10
echo "Press and hold the power button until the system powers off..."
}

clean () {
lsb_release -a
apt update
apt -y upgrade
apt -y full-upgrade
apt -y autoremove
cat << EOF > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports focal main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports focal-security main restricted universe multiverse
EOF
#echo "# jammy" >> /etc/apt/sources.list
reboot
}

#jammy () {
# This area will halfway break the system.  It cant use usrmerge, cant redo the /bin dir.  apt update shows the system
# is up2date, but any attempts to install additional software, you get complaints from apt.

# Added to upgrade to 22.04
# apt install update-manager-core
# do-release-upgrade -d

# I will try it again without using the update manager
#lsb_release -a
#cat << EOF > /etc/apt/sources.list
#deb http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse
#deb http://ports.ubuntu.com/ubuntu-ports jammy-updates main restricted universe multiverse
#deb http://ports.ubuntu.com/ubuntu-ports jammy-backports main restricted universe multiverse
#deb http://ports.ubuntu.com/ubuntu-ports jammy-security main restricted universe multiverse
#EOF
#apt update
#apt list --upgradable | egrep jammy | cut -d"/" -f1 | egrep -v "^lib"> upgrade.list; for file in `cat upgrade.list`; do echo -en "\n Installing $file \n" $file;apt -y install $file;done
#apt -y upgrade
#apt -y full-upgrade
#apt -y autoremove
#reboot
#}

if [ -z $state ]; then
        echo "Latest tested version installed..."
else
        echo "Starting with $state"
        $state
fi
