#!/bin/bash

TARGET="/opt/vpsadmininstall"

yum -y -q install git
#git clone git://git.vpsfree.cz/vpsadmininstall.git "$TARGET"

cd "$TARGET"

./installer/vpsadmin_node.sh
