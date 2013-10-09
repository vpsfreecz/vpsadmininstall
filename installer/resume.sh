#!/bin/bash

CFG_VPSADMIN="$1/tmp/vpsadmin_config.sh"
CFG_NODE="$1/tmp/node_config.sh"

function cleanup {
	sed -r -i 's/^.+vpsadmininstall\/installer\/resume\.sh.+$//' /etc/rc.d/rc.local
}

cd "$1"
. installer/functions.sh

echo ""
echo ""

if [ -f "$CFG_VPSADMIN" ] ; then
	echo "Resuming installation of vpsAdmin cluster"
	
	. "$CFG_VPSADMIN"
	. "$1/installer/vpsadmin_install.sh"
	
	if [ "$DEBUG" == "yes" ] ; then
		mv "$CFG_VPSADMIN" "$CFG_VPSADMIN.done"
	else
		rm -f "$CFG_VPSADMIN"
	fi
	
elif [ -f "$CFG_NODE" ] ; then
	echo "Resuming installation of a new node into vpsAdmin cluster"
	
	. "$CFG_NODE"
	. "$1/installer/node_install.sh"
	
	if [ "$DEBUG" == "yes" ] ; then
		mv "$CFG_NODE" "$CFG_NODE.done"
	else
		rm -f "$CFG_NODE"
	fi
	
else
	echo "Oops! There is nothing to resume!"
	cleanup
	exit 1
fi

if [ "$DEBUG" != "yes" ] ; then
	title "Cleaning up..."
	run tmp_cleanup
fi

cleanup

echo ""
echo "DONE!"
