#!/bin/bash

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

title "Database access"
read_valid "Host:" DB_HOST .+
read_valid "User:" DB_USER .+
read_valid "Password": DB_PASS .+
read_valid "Database name:" DB_NAME .+

title "Node"
read_valid "Node name:" NODE_NAME .+
read_valid "Cluster domain:" DOMAIN .+
read_valid "Node role (node, storage, mailer):" NODE_ROLE '^node$|^storage$|^mailer$' "not valid node role"
read_valid "Location (ID or label):" NODE_LOC .+
read_valid "IP address of this node:" NODE_IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
read_valid "IP address of vpsAdmin frontend" IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"

if [ "$NODE_ROLE" == "node" ] ; then
	read_valid "Maximum VPS number:" NODE_MAXVPS [0-9]+ "not valid number"
	read_valid "VE private (expands %{veid}):" NODE_VE_PRIVATE .+
	read_valid "FS type (ext4, zfs, zfs_compat):" NODE_FSTYPE '^ext4$|^zfs$|^zfs_compat$' "not valid FS type"
	
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
