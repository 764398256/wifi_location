tx_power='conf/tx_power'
tx_rate='conf/tx_rate'
gw=192.168.1.1
tf_rate=default
status=test2
timestamp=$(date +"%T")
interval=60
twait=20
echo "start testing at $timestamp"
mkdir ../data/${timestamp}
scp hooker.sh root@$gw:~
for power in `cat $tx_power`
do
    echo $power
	ssh root@$gw "sh hooker.sh $power"
	sleep $twait
	echo "Start capture at $timestamp"
	f_path="../data/${timestamp}/csi_${power}_${tf_rate}_${status}.dat"
	echo $f_path
	sudo ../linux-80211n-csitool-supplementary/netlink/log_to_file $f_path &
	PID=$!
	sleep $interval
	kill -INT $PID
	echo "Finish capture at $(date +"%T") for param: $power mW, $tf_rate Mbps, Home State($status) "
done
echo "finish testing at "$(date +"%T")
