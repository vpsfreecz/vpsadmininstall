#!/bin/bash

. functions.sh

EXECUTABLES="vzctl"
TEMPLATE="scientific-6-x86_64"
DOMAIN="your.domain"
IP_ADDR=""
NAMESERVER="8.8.8.8"
PACKAGES="httpd php mysql-server mysql php-mysql git expect"

if [ "$VEID" == "" ] ; then
	VEID=101
fi

DB_HOST="localhost"
DB_USER="vpsadmin"
DB_PASS=""
DB_NAME="vpsadmin"
DB_SOCK="/var/lib/mysql/mysql.sock"

VPSADMIN_ROOT="/opt/vpsadmin"
VPSADMIN_USERNAME="admin"

echo "vpsAdmin Cluster Installer"
echo "------        ------------"
echo "This installer will create a container and install vpsAdmin inside it."
echo "Some more info..."
echo ""
read -p "Press enter to continue"
echo ""

if [ "$DEBUG" == "yes" ] ; then
	read_valid "To which CT do you want to install vpsAdmin?" VEID [0-9]+ "not valid VEID"
fi

read_valid "What IP address should vpsAdmin frontend use?" IP_ADDR [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ "not valid IPv4 address"
read_valid "What is your cluster FQDN? Nodes will run on subdomains" DOMAIN .+

HOSTNAME="vpsadmin.$DOMAIN"

read_valid "What FQDN should vpsAdmin run on?" HOSTNAME .+
read_valid "What nameserver should vpsAdmin use?" NAMESERVER .+

VE_PRIVATE="/vz/private/$VEID"

echo ""
echo ""

title "Creating VE..."
run vzctl create $VEID --ostemplate $TEMPLATE --hostname $HOSTNAME
run vzctl set $VEID --ipadd $IP_ADDR --nameserver $NAMESERVER --ram 4G --swap 0 --save
run vzctl start $VEID

title "Installing packages..."
ve_run yum -y install $PACKAGES
ve_run chkconfig httpd on
ve_run chkconfig mysqld on
ve_run /etc/init.d/mysqld start

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

echo ""
msg "Setting password for MySQL root to: $DB_ROOT_PASS"
msg "Setting password for MySQL vpsadmin user: $DB_PASS"
msg "Save these!"
echo ""

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
ve_run mysql -u $DB_USER -p\'$DB_PASS\' $DB_NAME < ${VE_PRIVATE}${VPSADMIN_ROOT}/scripts/scheme.sql

# Create admin user
msg "Creating admin user"
ADMIN_PASS=`vzctl exec $VEID mkpasswd -l 10 -s 0`
ADMIN_PASS_HASH=`echo -n "${VPSADMIN_USERNAME}${ADMIN_PASS}" | md5sum | cut -d' ' -f1`
db_query "USE $DB_NAME ; INSERT INTO members SET m_id=1,m_created=UNIX_TIMESTAMP(NOW()),m_level=99,m_nick='$VPSADMIN_USERNAME',m_pass='$ADMIN_PASS_HASH';"

msg "Loading default configuration"
db_query "INSERT INTO locations SET location_id=1, location_label='Default location',location_has_ipv6=0,location_remote_console_server='http://$HOSTNAME:4567';"

title "Configuring web server..."
cat > $VE_PRIVATE/etc/httpd/conf.d/vpsadmin.conf <<EOF_HTTPD
<VirtualHost *:80>
	ServerName   $HOSTNAME
	DocumentRoot $VPSADMIN_ROOT
</VirtualHost>

EOF_HTTPD

title "Installing vpsAdmind..."
cat > install_node.tmp <<EOF_INSTALL
#!/bin/bash

DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME
DOMAIN=$DOMAIN
IP_ADDR=$IP_ADDR
NODE_ID=1
NODE_NAME=vpsadmin
NODE_ROLE=mailer
NODE_LOC=1

SKIP_INTRO="yes"
SKIP_PROMPT="yes"

EOF_INSTALL

cat functions.sh >> install_node.tmp
cat install_node.sh >> install_node.tmp

vzctl runscript $VEID install_node.tmp

# FIXME uncomment
#rm install_node.tmp

cp $VE_PRIVATE/$VPSADMIND_ROOT/thin.yml $VE_PRIVATE/etc/vpsadmin/thin.yml
sed -i -r "s/(address:) [^\$]+/\1 $IP_ADDR/" $VE_PRIVATE/etc/vpsadmin/thin.yml

cat >> $VE_PRIVATE/etc/rc.local <<EOF_LOCAL
thin -C /etc/vpsadmin/thin.yml start

EOF_LOCAL

# FIXME load default db data

title "Restarting VE..."
run vzctl restart $VEID

echo ""
echo "MySQL root password:     $DB_ROOT_PASS"
echo "MySQL vpsadmin password: $DB_PASS"
echo "Password for vpsadmin user will be needed to install nodes."
echo ""
echo "vpsAdmin is running at http://$HOSTNAME/"
echo "  Username: $VPSADMIN_USERNAME"
echo "  Password: $ADMIN_PASS"
echo "DONE!"
