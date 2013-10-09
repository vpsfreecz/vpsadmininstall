#!/bin/bash

PACKAGES="mysql mysql-devel ruby ruby-devel rubygems git iptables iptables-ipv6"
GEMS="bundler"
NODE_ID=0

function vpsadmind_config {
	cat > /etc/vpsadmin/vpsadmind.yml <<EOF
# vpsAdmind config file

:db:
    :host: $DB_HOST
    :user: $DB_USER
    :pass: $DB_PASS
    :name: $DB_NAME

:vpsadmin:
    :server_id: $NODE_ID
    :domain: $DOMAIN
    :threads: 4

:console:
    :host: $NODE_IP_ADDR
    :port: 8081

EOF
}

title "Adjusting firewall..."
run iptables --flush

if [ "$NODE_ROLE" == "node" ] ; then
	run iptables -A INPUT -s $IP_ADDR -p tcp --dport 8081 -j ACCEPT
	run iptables -A INPUT -p tcp --dport 8081 -j DROP
fi

run service iptables save

# openvz is somehow blocking module iptable_filter
# to restart iptables, vpses must be stopped
# useful only for vpsadmin_install.sh
if [ "$IPTABLES_RESTART" != "no" ] ; then
	run service iptables restart
fi

title "Installing packages..."
run yum -y groupinstall "Development Tools"
run yum -y install $PACKAGES
run gem install $GEMS

title "Installing vpsAdmind..."
msg "Fetching sources"
run git clone ${GIT_REPO}vpsadmind.git $VPSADMIND_ROOT
run cd $VPSADMIND_ROOT
# FIXME REMOVE
run git checkout devel
run bundle install
run ln -s $VPSADMIND_ROOT/scripts/vpsadmind.init /etc/init.d/vpsadmind
run ln -s $VPSADMIND_ROOT/scripts/vpsadmind.logrotate /etc/logrotate.d/vpsadmind
run mkdir -m 0700 -p /root/.ssh

msg "Creating configs"
run mkdir -p /etc/vpsadmin

run vpsadmind_config

cat > /etc/sysconfig/vpsadmind <<EOF
# Configuration file for the vpsadmind service.

# yes or no
#DAEMON=yes
OPTS="$VPSADMIND_OPTS"

#PIDFILE=/var/run/vpsadmind.pid
#LOGFILE=/var/log
#CONFIG=/etc/vpsadmin/vpsadmind.yml
EOF

run chkconfig vpsadmind on

title "Installing vpsAdminctl..."
msg "Fetching sources"
run git clone ${GIT_REPO}vpsadminctl.git $VPSADMINCTL_ROOT
run cd $VPSADMINCTL_ROOT
# FIXME REMOVE
run git checkout devel
run bundle install
run ln -s $VPSADMINCTL_ROOT/vpsadminctl.rb /usr/local/bin/vpsadminctl

title "Registering node..."
msg "Starting vpsAdmind"
run /etc/init.d/vpsadmind start
run sleep 5

msg "Registering"
# Do not generate configs before vpsAdmind knows the fs type
cmd="vpsadminctl install -p --name $NODE_NAME --role $NODE_ROLE --location $NODE_LOC --addr $NODE_IP_ADDR --no-propagate --no-generate-configs"

if [ "$NODE_ROLE" == "node" ] ; then
	cmd="$cmd --maxvps $NODE_MAXVPS --ve-private $NODE_VE_PRIVATE --fstype $NODE_FSTYPE"
fi

if [ "$DEBUG" == "yes" ] ; then
	run_info "$cmd"
fi

NODE_ID="`$cmd`"

run vpsadmind_config

run vpsadminctl restart
run sleep 5

if [ "$NODE_ROLE" == "node" ] ; then
	run vpsadminctl install --no-create --propagate --generate-configs
fi
