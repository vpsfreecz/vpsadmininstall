#!/bin/bash

. installer/functions.sh

NODE_MAXVPS=30
NODE_VE_PRIVATE="/vz/private/%{veid}"
NODE_FSTYPE="ext4"

VPSADMIND_OPTS="--export-console --remote-control"

STANDALONE="yes"

echo "vpsAdmin Node Installer"
echo "-----------------------"
echo "This installer will install a new node into your vpsAdmin cluster."
echo ""
read -p "Press enter to continue"
echo ""
echo ""

if [ -f "$VPSADMIN_NODE_INFO" ] ; then
	title "Using provided node configuration file..."
	. "$VPSADMIN_NODE_INFO"
	
	INFO_PROVIDED=yes
fi

if [ "$INFO_PROVIDED" != "yes" ] ; then
	title "Database access"
	read_valid "Host" DB_HOST .+
	read_valid "User" DB_USER .+
	read_valid "Password": DB_PASS .+
	read_valid "Database name" DB_NAME .+
fi

title "Node"
read_valid "Node name:" NODE_NAME .+

if [ "$INFO_PROVIDED" != "yes" ] ; then
	read_valid "Cluster domain" DOMAIN .+
fi

read_valid "Node role (node, storage, mailer)" NODE_ROLE '^node$|^storage$|^mailer$' "not valid node role"
read_valid "Location (ID or label)" NODE_LOC .+
read_valid "IP address of this node" NODE_IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"

if [ "$INFO_PROVIDED" != "yes" ] ; then
	read_valid "IP address of vpsAdmin frontend" IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
fi

if [ "$NODE_ROLE" == "node" ] ; then
	read_valid "FS type (ext4, zfs, zfs_compat)" NODE_FSTYPE '^ext4$|^zfs$|^zfs_compat$' "not valid FS type"
	
	if [ "$NODE_FSTYPE" == "zfs" ] || [ "$NODE_FSTYPE" == "zfs_compat" ] ; then
		echo ""
		echo "Please keep in mind, that you have to manually set up zpool to install ZFS node."
		echo ""
		
		NODE_VE_PRIVATE="$NODE_VE_PRIVATE/private"
	fi
	
	read_valid "Maximum VPS number" NODE_MAXVPS [0-9]+ "not valid number"
	read_valid "VE private (expands %{veid})" NODE_VE_PRIVATE .+
	
else
	VPSADMIN_OPTS="--remote-control"
fi

cat > tmp/node_config.sh <<EOF
DB_HOST="$DB_HOST"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
NODE_NAME="$NODE_NAME"
NODE_ROLE="$NODE_ROLE"
NODE_LOC="$NODE_LOC"
NODE_IP_ADDR="$NODE_IP_ADDR"
IP_ADDR="$IP_ADDR"
NODE_MAXVPS="$NODE_MAXVPS"
NODE_VE_PRIVATE="$NODE_VE_PRIVATE"
NODE_FSTYPE="$NODE_FSTYPE"
VPSADMIND_OPTS="$VPSADMIND_OPTS"

DEBUG="$DEBUG"

EOF

. installer/vz.sh
