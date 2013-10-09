#!/bin/bash

. installer/functions.sh

TEMPLATE="scientific-6-x86_64"
DOMAIN="your.domain"
IP_ADDR=""
NAMESERVER="8.8.8.8"
NODE_FSTYPE="ext4"

if [ "$VEID" == "" ] ; then
	VEID=101
fi

DB_HOST="localhost"
DB_USER="vpsadmin"
DB_PASS=""
DB_NAME="vpsadmin"
DB_SOCK="/var/lib/mysql/mysql.sock"

STANDALONE="yes"

echo "vpsAdmin Cluster Installer"
echo "--------------------------"
echo "This installer will install OpenVZ, then reboot the system and continue"
echo "installing vpsAdmin cluster."
echo ""
read -p "Press enter to continue"
echo ""

if [ "$DEBUG" == "yes" ] ; then
	read_valid "To which CT do you want to install vpsAdmin?" VEID [0-9]+ "not valid VEID"
fi

read_valid "What IP address should vpsAdmin frontend use? (IP of container)" IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
read_valid "What IP address should use vpsAdmin daemon? (IP of CT0/HW node)" NODE_IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
read_valid "CT0/HW node FS type (ext4, zfs, zfs_compat):" NODE_FSTYPE '^ext4$|^zfs$|^zfs_compat$' "not valid FS type"
read_valid "What is your cluster domain? Nodes will run on subdomains" DOMAIN .+

HOSTNAME="vpsadmin.$DOMAIN"

read_valid "What FQDN should vpsAdmin run on?" HOSTNAME .+
read_valid "What nameserver should vpsAdmin use?" NAMESERVER .+

VE_PRIVATE="/vz/private/$VEID"
DB_HOST="$IP_ADDR"

echo ""
echo ""

if [ "$NODE_FSTYPE" == "ext4" ] ; then
	NODE_VE_PRIVATE="/vz/private/%{veid}"
else
	NODE_VE_PRIVATE="/vz/private/%{veid}/private"
fi

cat > tmp/vpsadmin_config.sh <<EOF
TEMPLATE="$TEMPLATE"
DOMAIN="$DOMAIN"
IP_ADDR="$IP_ADDR"
NODE_IP_ADDR="$NODE_IP_ADDR"
NAMESERVER="$NAMESERVER"
VEID="$VEID"
DB_HOST="$DB_HOST"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
DB_SOCK="$DB_SOCK"
HOSTNAME="$HOSTNAME"
VE_PRIVATE="$VE_PRIVATE"

NODE_MAXVPS=30
NODE_VE_PRIVATE="$NODE_VE_PRIVATE"
NODE_FSTYPE="$NODE_FSTYPE"

VPSADMIND_OPTS="--export-console --remote-control"

DEBUG="$DEBUG"

EOF

. installer/vz.sh
