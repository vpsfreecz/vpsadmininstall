echo ""
title "Server will reboot in 15 seconds, installation will continue"

if [ "$DEBUG" != "yes" ] ; then
	run sleep 15
	run reboot
fi
