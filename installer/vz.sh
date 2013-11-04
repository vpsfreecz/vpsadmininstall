#!/bin/bash

set_install_state "installing"

title "Installing OpenVZ..."
msg "Configuring repository"
run curl -so /etc/yum.repos.d/openvz.repo http://ftp.openvz.org/openvz.repo
run rpm --import http://ftp.openvz.org/RPM-GPG-Key-OpenVZ

msg "Installing vzkernel and vzctl"
run yum -y install vzkernel vzkernel-devel vzctl
run chkconfig vz off

title "Configuring OpenVZ..."

if [ "$NODE_FSTYPE" == "zfs" ] || [ "$NODE_FSTYPE" == "zfs_compat" ] ; then
	msg "Disabling vzquota"
	run sed -i 's/^DISK_QUOTA=yes$/DISK_QUOTA=no/' /etc/vz/vz.conf
fi

echo "$BASEDIR/installer/resume.sh \"$BASEDIR\"" >> /etc/rc.d/rc.local

echo ""
title "Server will reboot in 15 seconds, installation will continue"

if [ "$DEBUG" != "yes" ] ; then
	run sleep 15
	run reboot
fi

exit
