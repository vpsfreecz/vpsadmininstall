#!/bin/bash

set_install_state "installing"

title "Installing OpenVZ..."
msg "Configuring repository"
run curl -so /etc/yum.repos.d/openvz.repo http://ftp.openvz.org/openvz.repo
run rpm --import http://ftp.openvz.org/RPM-GPG-Key-OpenVZ

msg "Installing vzkernel and vzctl"
run yum -y install vzkernel vzkernel-devel vzctl

title "Configuring OpenVZ..."

if [ "$NODE_FSTYPE" == "zfs" ] || [ "$NODE_FSTYPE" == "zfs_compat" ] ; then
	msg "Disabling vzquota"
	run sed -i 's/^DISK_QUOTA=yes$/DISK_QUOTA=no/' /etc/vz/vz.conf
fi

. installer/reboot.sh

exit
