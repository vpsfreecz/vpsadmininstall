#!/bin/bash

TARGET="/opt/vpsadmininstall"
STATUS_FILE="/root/vpsadmin.status"
LOGFILE="/root/vpsadmin-install.log"

function run {
	$* >> $LOGFILE 2>&1
	
	ret="$?"
	if [ "$ret" != "0" ] ; then
		echo "Command '$*' exited with code $ret."
		echo "Check $LOGFILE for errors."
		exit 1
	fi
}

if [ -f "$STATUS_FILE" ] && [ "`cat $STATUS_FILE`" == "installing" ] ; then
	echo "It seems that installation is already in progress."
	echo "If you know that it is not so, please remove file '$STATUS_FILE'"
	echo "and start installer again."
	
	exit 1
fi

which git > /dev/null 2>&1

if [ "$?" != "0" ] ; then
	echo "* Installing git..."
	run yum -y -q install git
	echo ""
fi

if [ "$VPSADMIN_CLONE" != "no" ] ; then
	run git clone git://git.vpsfree.cz/vpsadmininstall.git "$TARGET"
	run git pull
fi

cd "$TARGET"

tty -s
if [ "$?" == "0" ] ; then
	./installer/vpsadmin_intro.sh
	
else
	PARENT_TTY="`readlink /proc/$PPID/fd/0`"
	./installer/vpsadmin_intro.sh < $PARENT_TTY > $PARENT_TTY 2> $PARENT_TTY
fi
