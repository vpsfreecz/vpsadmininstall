# Define IP address which will be pinged
CHECKIP="8.8.8.8"

echo "Waiting for network... [hit several keys to interrupt]"
keypress=""
ping $CHECKIP -c 4 > /dev/null
while [ ! $? -eq 0 ]; do
        echo -n ".";
        ping $CHECKIP -c 1 > /dev/null 2>&1
        read -n 1 -t 1 keypress
        if [ "$keypress" != "" ]; then
            echo " interrupted."
            break;
        fi;
done;
echo "ok."
