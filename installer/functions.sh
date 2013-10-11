#!/bin/bash

LOGFILE="/root/vpsadmin-install.log"
GIT_REPO="git://git.vpsfree.cz/"
VPSADMIND_ROOT="/opt/vpsadmind"
VPSADMINCTL_ROOT="/opt/vpsadminctl"
VPSADMIN_ROOT="/opt/vpsadmin"
VPSADMIN_USERNAME="admin"
VPSADMIN_NODE_INFO="/root/vpsadmin-node.txt"

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
		
Installation failed, command '$*' returned exit code $ret."
Check log file at $LOGFILE"

Before retrying the installation, destroy CT $VEID with:"
    vzctl stop $VEID && vzctl destroy $VEID"

EOF_ERR
		
		cat /root/vpsadmin.status
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

function title {
	if [ "$STANDALONE" != "no" ] ; then
		echo "* $*"
	else
		echo "  * $*"
	fi
}

function msg {
	if [ "$STANDALONE" != "no" ] ; then
		echo "  > $*"
	else
		echo "    > $*"
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
