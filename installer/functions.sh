#!/bin/bash

LOGFILE="/root/vpsadmin-install.log"
GIT_REPO="git://git.vpsfree.cz/"
VPSADMIND_ROOT="/opt/vpsadmind"
VPSADMINCTL_ROOT="/opt/vpsadminctl"
VPSADMIN_ROOT="/opt/vpsadmin"
VPSADMIN_USERNAME="admin"
VPSADMIN_NODE_INFO="/root/vpsadmin-node.txt"
VPSADMIN_PROGRESS="/root/vpsadmin.progress"

BASEDIR="`pwd`"

export PATH="$PATH:/usr/local/bin"

function run_info {
	echo "RUN $*"
}

function run {
	if [ "$DEBUG" == "yes" ] ; then
		run_info $*
		$*
	
	else
		echo "$*" >> $LOGFILE
		$* >> $LOGFILE 2>&1
	fi
	
	local ret=$?
	
	if [ $ret != 0 ] ; then
		cat > /root/vpsadmin.status <<EOF_ERR
		
Installation failed, command '$*' returned exit code $ret.
Check log file at $LOGFILE".

Before retrying the installation, please run either:
	$BASEDIR/reset.sh
or
	curl -ko- "https://git.vpsfree.cz/?p=vpsadmininstall.git;a=blob_plain;f=reset.sh;hb=HEAD" | bash

EOF_ERR
		
		cat /root/vpsadmin.status | tee -a "$VPSADMIN_PROGRESS"
		exit 1
	fi
}

function ve_run {
	run vzctl exec2 $VEID $*
}

function db_query {
	if [ "$DEBUG" == "yes" ] ; then
		echo "SQL Query: '$1'"
	fi
	
	echo "$1" | ve_run mysql -u root -p\'$DB_ROOT_PASS\'
}

function db_import {
	ve_run mysql -u $DB_USER -p\'$DB_PASS\' $DB_NAME < $1
}

function read_valid {
	local default=`eval echo -n \\$$2`
	
	while true
	do
		read -p "$1 [$default]: " input
		
		if [[ $input == "" && $default == "" ]] ; then
			echo "No input given"
		
		elif [[ $input == "" ]] ; then
			break
		
		elif [[ $input =~ $3 ]] ; then
			eval $2="$input"
			break
		
		else
			echo "Bad format: $4"
		fi
	done
}

function progress {
	echo "$*" | tee -a "$VPSADMIN_PROGRESS"
}

function title {
	if [ "$STANDALONE" != "no" ] ; then
		progress "* $*"
	else
		progress "  * $*"
	fi
}

function msg {
	if [ "$STANDALONE" != "no" ] ; then
		progress "  > $*"
	else
		progress "    > $*"
	fi
}

function tmp_cleanup {
	run cd "$BASEDIR"
	run rm -f tmp/*
}

function set_install_state {
	echo "$1" > /root/vpsadmin.status
}

function get_default_addr {
	local INTERFACE="`ip r s | grep default | grep -oP 'dev\ [a-zA-Z0-9-.]+' | sed 's/dev\ //g'`"
	
	if [ "$INTERFACE" != "" ] ; then
		eval $1="`ip a s dev $INTERFACE | grep "inet " | awk '{ print $2; }' | cut -d'/' -f1`"
	fi
}

function get_vz_fs {
	local MOUNTS="`mount | grep /vz`"
	
	for m in "$MOUNTS" ; do
		if [ "`echo -n $m | cut -d ' ' -f3`" == "/vz" ] ; then
			NODE_FSTYPE="`echo -n $m | cut -d ' ' -f5`"
			
			if [ "$NODE_FSTYPE" != "ext4" ] && [ "$NODE_FSTYPE" != "zfs" ] ; then
				NODE_FSTYPE=ext4
				
			elif [ "$NODE_FSTYPE" == "zfs" ] ; then
				NODE_FSTYPE=zfs_compat
			fi
		fi
	done
	
	if [ "$DEBUG" == "yes" ] ; then
		echo "Auto-detected node FS type to '$NODE_FSTYPE'"
	fi
}
