#!/bin/bash

function run {
	$* > /dev/null 2>&1
}

run rm -f /root/vpsadmin*
run vzctl stop 101
run vzctl destroy 101
run rm -rf /opt/vpsadmind /opt/vpsadminctl
run rm -f /etc/init.d/vpsadmind /etc/logrotate.d/vpsadmind /etc/sysconfig/vpsadmind /usr/local/bin/vpsadminctl

cat > /etc/rc.d/rc.local <<EOF
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

EOF

echo "ok"
