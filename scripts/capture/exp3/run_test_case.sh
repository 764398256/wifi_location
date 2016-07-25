#btype_conf='conf/barriertype'
gw=192.168.1.1
# tx_power= 200mW, tx_rate=default
#btype=metal
timestamp=$(date +"%T")
interval=40
twait=10
echo "start testing at $timestamp"
folder='data'
logging_bin_path='../../../../linux-80211n-csitool-supplementary/netlink/'
mkdir -p $folder
for length in `seq 0 0.5 5`
do
    for width in `seq 0 0.5 3`
    do
        param=${length}_${width}
        sleep $twait
        echo "Start capture at $timestamp"
        f_path="${folder}/csi_${param}.dat"
        echo $f_path
        sudo ${logging_bin_path}log_to_file $f_path &
        PID=$!
        sleep $interval
        sudo kill -INT $PID
        echo "Finish capture at $(date +"%T") for param: $param "
done
done
echo "finish testing at "$(date +"%T")
