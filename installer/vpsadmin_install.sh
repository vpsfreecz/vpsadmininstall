#!/bin/bash

PACKAGES="httpd php mysql-server mysql php-mysql git expect"
VPSADMIN_READY="/root/vpsadmin.ready"

title "Adjusting firewall..."
run iptables --flush
run service iptables save
run service iptables restart

title "Creating VE..."
run vzctl create $VEID --ostemplate $TEMPLATE --hostname $HOSTNAME
run vzctl set $VEID --ipadd $IP_ADDR --nameserver $NAMESERVER --ram 4G --swap 0 --save
run vzctl start $VEID
run sleep 5

title "Configuring web server..."
run cp installer/data/httpd/conf/* $VE_PRIVATE/etc/httpd/conf/
run cp installer/data/httpd/conf.d/ $VE_PRIVATE/etc/httpd/conf.d/
run cp installer/data/httpd/www/* $VE_PRIVATE/var/www/html/
ve_run service httpd restart

title "Installing packages..."
ve_run yum -y install $PACKAGES
ve_run chkconfig httpd on
ve_run chkconfig mysqld on
ve_run service mysqld start

title "Configuring database..."
msg "Edit my.cnf"
cat > $VE_PRIVATE/etc/my.cnf <<EOF_MY
#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

[mysqld]
innodb_buffer_pool_size=512M
innodb_log_buffer_size=4M
innodb_flush_log_at_trx_commit=2
innodb_thread_concurrency=8
innodb_flush_method=O_DIRECT
transaction-isolation=READ-COMMITTED

expire_logs_days        = 10
max_binlog_size         = 1000M

key_buffer              = 96M
max_allowed_packet      = 64M
thread_stack            = 256K
thread_cache_size       = 32

myisam-recover          = BACKUP
max_connections        = 1000
table_cache            = 512
thread_concurrency     = 15
join_buffer_size       = 1M
low_priority_updates=1
concurrent_insert=2
read_buffer_size=256k

bind-address            = 0.0.0.0

query_cache_type         = 1
query_cache_limit        = 256K
query_cache_size         = 256M
query_cache_min_res_unit = 4K

EOF_MY

DB_ROOT_PASS=`vzctl exec $VEID mkpasswd -l 20 -s 0`
DB_PASS=`vzctl exec $VEID mkpasswd -l 20 -s 0`
ve_run mysqladmin -u root password \'$DB_ROOT_PASS\'

# Remove anonymous users and test database
msg "Removing anonymous users and test database"
db_query "DELETE FROM mysql.user WHERE User='';"
db_query "DROP DATABASE test;"
db_query "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

# Create vpsadmin user
msg "Creating vpsAdmin user"
db_query "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
db_query "GRANT USAGE ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;"
db_query "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
db_query "GRANT ALL PRIVILEGES ON \`$DB_USER\`.* TO '$DB_USER'@'%';"

title "Installing vpsAdmin..."
msg "Fetching sources"
ve_run git clone ${GIT_REPO}vpsadmin.git $VPSADMIN_ROOT

if [ "$VPSADMIN_DEVEL" == "yes" ] ; then
	run cd "$VE_PRIVATE/$VPSADMIN_ROOT"
	run git checkout devel
	run cd "$BASEDIR"
fi

msg "Creating config"
ve_run mkdir -m 0750 /etc/vpsadmin
ve_run chown :apache /etc/vpsadmin

cat > $VE_PRIVATE/etc/vpsadmin/config.php <<EOF_CONFIG
<?php
define ('DB_HOST', '$DB_HOST');
define ('DB_USER', '$DB_USER');
define ('DB_PASS', '$DB_PASS');
define ('DB_NAME', '$DB_NAME');
define ('DB_SOCK', '$DB_SOCK');

define ('WWW_ROOT', "$VPSADMIN_ROOT/");
define ('PRIV_POORUSER', 1);
define ('PRIV_USER', 2);
define ('PRIV_POWERUSER', 3);
define ('PRIV_ADMIN', 21);
define ('PRIV_SUPERADMIN', 90);
define ('PRIV_GOD', 99);
define ('TRACKING_CODE', '');

define ('NAS_PUBLIC', true);

EOF_CONFIG

# Create DB scheme
msg "Creating database scheme"
db_query "FLUSH PRIVILEGES;"
db_import ${VE_PRIVATE}${VPSADMIN_ROOT}/scripts/scheme.sql

# Create admin user
msg "Creating admin user"
ADMIN_PASS=`vzctl exec $VEID mkpasswd -l 10 -s 0`
ADMIN_PASS_HASH=`echo -n "${VPSADMIN_USERNAME}${ADMIN_PASS}" | md5sum | cut -d' ' -f1`
db_query "USE $DB_NAME ; INSERT INTO members SET m_id=1,m_created=UNIX_TIMESTAMP(NOW()),m_level=99,m_nick='$VPSADMIN_USERNAME',m_pass='$ADMIN_PASS_HASH';"

msg "Loading default configuration"
db_query "USE $DB_NAME ; INSERT INTO locations SET location_id=1, location_label='Default location',location_has_ipv6=0,location_remote_console_server='http://$HOSTNAME:4567';"

db_import installer/db/cfg_templates.sql
db_import installer/db/config.sql
db_import installer/db/sysconfig.sql
db_import installer/db/cfg_dns.sql

db_query "USE $DB_NAME ; INSERT INTO cfg_dns SET dns_ip='$NAMESERVER',dns_label='$NAMESERVER',dns_location=1;"
db_query "USE $DB_NAME ; INSERT INTO vps SET vps_id=$VEID,vps_created=UNIX_TIMESTAMP(NOW()),m_id=1,vps_hostname='$HOSTNAME',vps_template=1,vps_nameserver='$NAMESERVER',vps_server=2;"
db_query "USE $DB_NAME ; INSERT INTO vps_ip SET vps_id=$VEID,ip_v=4,ip_location=1,ip_addr='$IP_ADDR';"
db_query "USE $DB_NAME ; INSERT INTO vps_has_config (vps_id,config_id,\`order\`) VALUES ($VEID,27,1), ($VEID,28,2), ($VEID,6,3), ($VEID,22,4);"
db_query "USE $DB_NAME ; INSERT INTO sysconfig SET cfg_name='general_base_url', cfg_value='\"http:\/\/$HOSTNAME\/\"';"
db_query "USE $DB_NAME ; ALTER TABLE vps AUTO_INCREMENT=$(($VEID+1));"

# Install mailer inside CT with vpsAdmin
title "Installing vpsAdmind as mailer..."
run cd "$BASEDIR"

cat > tmp/node_install.sh <<EOF_INSTALL
#!/bin/bash

DB_HOST="$DB_HOST"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
DOMAIN="$DOMAIN"
NODE_IP_ADDR="$IP_ADDR"
IP_ADDR="$IP_ADDR"
NODE_NAME=vpsadmin
NODE_ROLE=mailer
NODE_LOC=1
VPSADMIND_OPTS="--remote-control"

STANDALONE="no"
VPSADMIN_DEVEL="$VPSADMIN_DEVEL"
DEBUG="$DEBUG"

EOF_INSTALL

cat installer/functions.sh installer/node_install.sh >> tmp/node_install.sh

vzctl runscript $VEID tmp/node_install.sh

# Install vpsAdmind on CT0
title "Installing vpsAdmind as node..."
NODE_NAME="`hostname`"
NODE_ROLE=node
NODE_LOC=1

STANDALONE="no"
IPTABLES_RESTART="no"

. installer/node_install.sh


STANDALONE="yes"

# Configure console router
title "Configuring console router..."
run cp $VE_PRIVATE/$VPSADMIND_ROOT/thin.yml $VE_PRIVATE/etc/vpsadmin/thin.yml
sed -i -r "s/(address:) [^$]+/\1 $IP_ADDR/" $VE_PRIVATE/etc/vpsadmin/thin.yml

cat >> $VE_PRIVATE/etc/rc.local <<EOF_LOCAL
thin -C /etc/vpsadmin/thin.yml start

EOF_LOCAL

title "Configuring cron jobs..."
cat > $VE_PRIVATE/etc/cron.d/vpsadmin <<EOF_CRONTAB
### vpsAdmin cron jobs ###

SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# Notify users about expiration and payment
# Uncomment to enable
# 0 0 * * *       apache php /var/www/virtual/vpsadmin.vpsfree.cz/htdocs/cron_mailer.php

# Summary of nonpayers for admins
# Uncomment to enable
# 0 0 * * *       apache php /var/www/virtual/vpsadmin.vpsfree.cz/htdocs/cron_nonpayers.php

# Daily backups
# Uncomment to enable backups
# 0 1 * * *       apache ruby /opt/vpsadmind/backup.rb

# vpsAdmin lazy delete
50 0 * * *      apache php /var/www/virtual/vpsadmin.vpsfree.cz/htdocs/cron_delete.php

# Daily reports, informs admins about
# Uncomment to enable daily reports
# 0 9 * * *       apache ruby /opt/vpsadmind/daily_report.rb

EOF_CRONTAB

title "Configuring web server..."
cat > $VE_PRIVATE/etc/httpd/conf.d/vpsadmin.conf <<EOF_HTTPD
ServerName   $HOSTNAME
DocumentRoot $VPSADMIN_ROOT

<Directory "$VPSADMIN_ROOT">
    Options Indexes FollowSymLinks

    AllowOverride None

    Order allow,deny
    Allow from all
</Directory>

EOF_HTTPD

run rm -f $VE_PRIVATE/etc/httpd/conf.d/vpsadmin-installing.conf
run rm -f $VE_PRIVATE/var/www/html/index.html

title "Restarting VE..."
run service vpsadmind stop
run vzctl stop $VEID
run service iptables restart
run vzctl start $VEID
run sleep 10
run service vpsadmind start

title "Writing postinstall information..."
cat > "$VPSADMIN_READY" <<EOF_RDY
vpsAdmin Credentials
====================
Running at http://$HOSTNAME/

 - Username: $VPSADMIN_USERNAME
 - Password: $ADMIN_PASS

It is recommended to change the password.

Information needed to setup a node in cluster
---------------------------------------------
This information is also saved in a bash script at '$VPSADMIN_NODE_INFO'.
You can pass this file to the node installer and save yourself trouble
copy & pasting credentials manually.

## Database access
 - Host:          $DB_HOST
 - User:          $DB_USER
 - Password:      $DB_PASS
 - Database name: $DB_NAME

## Cluster info
 - Domain:                 $DOMAIN
 - IP address of frontend: $IP_ADDR

Database access
---------------
Password for MySQL root: $DB_ROOT_PASS

Feel free to change it, vpsAdmin won't need it anymore.

The vpsAdmin team.

EOF_RDY

cat > "$VPSADMIN_NODE_INFO" <<EOF_NODE
#!/bin/bash
# Information needed to setup nodes in cluster
# ============================================
## Database access:
# Host:
DB_HOST="$DB_HOST"
# User:
DB_USER="$DB_USER"
# Password:
DB_PASS="$DB_PASS"
# Database name:
DB_NAME="$DB_NAME"

## Cluster info
# Domain:
DOMAIN="$DOMAIN"

# IP address of vpsAdmin frontend
IP_ADDR="$IP_ADDR"

EOF_NODE

set_install_state "installed"
