#!/bin/bash

PACKAGES="mysql mysql-devel ruby ruby-devel rubygems git iptables iptables-ipv6"
GEMS="bundler"

NODE_MAXVPS=30
NODE_VE_PRIVATE="/vz/private/%{veid}"
NODE_FSTYPE="ext4"

if [ "$SKIP_INTRO" == "" ] ; then
	echo "vpsAdmin Node Installer"
	echo "-----------------------"
	echo "This installer will install a new node into your vpsAdmin cluster."
	echo ""
	read -p "Press enter to continue"
	echo ""
	echo ""
fi

if [ "$SKIP_PROMPT" != "yes" ] ; then
	title "Database access"
	read_valid "Host:" DB_HOST .+
	read_valid "User:" DB_USER .+
	read_valid "Password": DB_PASS .+
	read_valid "Database name:" DB_NAME .+
	
	title "Node"
	read_valid "ID:" NODE_ID [0-9]+ "not valid node ID"
	read_valid "Node name:" NODE_NAME .+
	read_valid "Cluster FQDN hostname:" DOMAIN .+
	read_valid "Node role (node, storage, mailer):" NODE_ROLE node|storage|mailer "not valid node role"
	read_valid "Location:" NODE_LOC .+
	read_valid "IP address:" IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
	
	if [ $NODE_ROLE == "node" ] ; then
		read_valid "Maximum VPS number:" NODE_MAXVPS [0-9]+ "not valid number"
		read_valid "VE private (expands %{veid}):" NODE_VE_PRIVATE .+
		read_valid "FS type (ext4, zfs, zfs_compat):" NODE_FSTYPE ext4|zfs|zfs_compat "not valid FS type"
	fi
fi

title "Installing packages..."
run yum -y groupinstall 'Development Tools'
run yum -y install $PACKAGES
run gem install $GEMS

title "Installing vpsAdmind..."
msg "Fetching sources"
run git clone ${GIT_REPO}vpsadmind.git $VPSADMIND_ROOT
run cd $VPSADMIND_ROOT
run bundle install
run ln -s $VPSADMIND_ROOT/scripts/vpsadmind.init /etc/init.d/vpsadmind
run ln -s $VPSADMIND_ROOT/scripts/vpsadmind.logrotate /etc/logrotate.d/vpsadmind

msg "Creating configs"
run mkdir -p /etc/vpsadmin

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
    :host: $IP_ADDR
    :port: 8081

EOF

cat > /etc/sysconfig/vpsadmind <<EOF
# Configuration file for the vpsadmind service.

# yes or no
#DAEMON=yes
OPTS="--export-console --remote-control"

#PIDFILE=/var/run/vpsadmind.pid
#LOGFILE=/var/log
#CONFIG=/etc/vpsadmin/vpsadmind.yml
EOF

run chkconfig vpsadmind on

title "Installing vpsAdminctl..."
msg "Fetching sources"
run git clone ${GIT_REPO}vpsadminctl.git $VPSADMINCTL_ROOT
run cd $VPSADMINCTL_ROOT
run bundle install
run ln -s $VPSADMINCTL_ROOT/vpsadminctl.rb /usr/local/bin/vpsadminctl

title "Registering node..."
msg "Starting vpsAdmind"
run /etc/init.d/vpsadmind start

msg "Registering"
cmd="vpsadminctl install --id $NODE_ID --name $NODE_NAME --role $NODE_ROLE --location $NODE_LOC --addr $IP_ADDR --propagate"

if [ $NODE_ROLE == "node" ] ; then
	cmd="$cmd --maxvps $NODE_MAXVPS --ve-private $NODE_VE_PRIVATE --fstype $NODE_FSTYPE"
fi

run "$cmd"

echo "DONE!"
