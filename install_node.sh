#!/bin/bash

TARGET="/opt/vpsadmininstall"

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
	./installer/node_intro.sh
	
else
	PARENT_TTY="`readlink /proc/$PPID/fd/0`"
	./installer/node_intro.sh < $PARENT_TTY > $PARENT_TTY 2> $PARENT_TTY
fi
