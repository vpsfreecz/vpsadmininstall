#!/bin/bash

CFG_VPSADMIN="$1/tmp/vpsadmin_config.sh"
CFG_NODE="$1/tmp/node_config.sh"

cd "$1"
. installer/functions.sh

if [ -f "$CFG_VPSADMIN" ] ; then
	echo "Resuming installation of vpsAdmin cluster"
	
	. "$CFG_VPSADMIN"
	. "$1/installer/vpsadmin_install.sh"
	
	mv "$CFG_VPSADMIN" "$CFG_VPSADMIN".deleted
	
elif [ -f "$CFG_NODE" ] ; then
	echo "Resuming installation of a new node into vpsAdmin cluster"
	
	. "$CFG_NODE"
	. "$1/installer/node_install.sh"
	
	mv "$CFG_NODE" "$CFG_NODE".deleted
	
else
	echo "Oops! There is nothing to resume!"
	exit 1
fi

sed -i 's/^# vpsadmininstall.+$//g' /etc/rc.local
