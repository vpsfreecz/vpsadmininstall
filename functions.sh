#!/bin/bash

LOGFILE="/root/vpsadmin-install.log"
GIT_REPO="git://git.vpsfree.cz/"
VPSADMIND_ROOT="/opt/vpsadmind"
VPSADMINCTL_ROOT="/opt/vpsadminctl"

function run {
	if [ "$DEBUG" == "yes" ] ; then
		echo "RUN $*"
		$*
	
	else
		echo "$*" >> $LOGFILE
		$* >> $LOGFILE 2>&1
	fi
	
	local ret=$?
	
	if [ $ret != 0 ] ; then
		echo "Installation failed, command '$*' returned exit code $ret."
		echo "Check log file at $LOGFILE"
		echo ""
		echo "Before retrying the installation, destroy CT $VEID with:"
		echo "    vzctl stop $VEID && vzctl destroy $VEID"
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
	echo "* $*"
}

function msg {
	echo "  > $*"
}
