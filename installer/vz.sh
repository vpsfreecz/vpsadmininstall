#!/bin/bash

title "Installing OpenVZ..."
msg "Configuring repository"
run wget -P /etc/yum.repos.d/ http://ftp.openvz.org/openvz.repo
run rpm --import http://ftp.openvz.org/RPM-GPG-Key-OpenVZ

msg "Installing vzkernel and vzctl"
run yum -y install vzkernel vzctl

echo "$BASEDIR/installer/resume.sh \"$BASEDIR\"" >> /etc/rc.d/rc.local

echo ""
title "Server will reboot in 15 seconds, installation will continue"

if [ "$DEBUG" != "yes" ] ; then
	run sleep 15
	run reboot
fi

exit
