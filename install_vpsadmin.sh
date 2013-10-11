#!/bin/bash

TARGET="/opt/vpsadmininstall"
STATUS_FILE="/root/vpsadmin.status"

if [ -f "$STATUS_FILE" ] && [ "`cat $STATUS_FILE`" == "installing" ] ; then
	echo "It seems that installation is already in progress."
	echo "If you know that it is not so, please remove file '$STATUS_FILE'"
	echo "and start installer again."
	
	exit 1
fi

which git > /dev/null 2>&1

if [ "$?" != "0" ] ; then
	echo "* Installing git..."
	yum -y -q install git >> /dev/null
	echo ""
fi

if [ "$VPSADMIN_CLONE" != "no" ] ; then
	git clone git://git.vpsfree.cz/vpsadmininstall.git "$TARGET" >> /dev/null
fi

cd "$TARGET"

tty -s
if [ "$?" == "0" ] ; then
	./installer/vpsadmin_intro.sh
	
else
	PARENT_TTY="`readlink /proc/$PPID/fd/0`"
	./installer/vpsadmin_intro.sh < $PARENT_TTY > $PARENT_TTY 2> $PARENT_TTY
fi
