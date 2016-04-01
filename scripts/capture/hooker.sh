echo "=============================="
echo "new_power:$1 mW"
echo "Params before change:"
/usr/sbin/nvram show | grep 'wl0_txpwr='
/usr/sbin/nvram set wl0_txpwr=$1
echo "Params after change:"
/usr/sbin/nvram show | grep 'wl0_txpwr='
/usr/sbin/nvram commit
stopservice wlconf
sleep 5
startservice wlconf

