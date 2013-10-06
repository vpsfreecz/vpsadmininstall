#!/bin/bash

TARGET="/opt/vpsadmininstall"

yum -y -q install git > /dev/null
#git clone git://git.vpsfree.cz/vpsadmininstall.git "$TARGET"

cd "$TARGET"

./installer/vpsadmin_intro.sh
