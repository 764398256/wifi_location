txrxloc_conf='conf/txrxloc'
#btype_conf='conf/barriertype'
gw=192.168.1.1
# tx_power= 200mW, tx_rate=default
# antenna relative posture: para, orth
antenna=para
# Room status: empty, barrier 
room=empty
#btype=metal
timestamp=$(date +"%T")
interval=60
twait=20
echo "start testing at $timestamp"
folder='data/case1'
logging_bin_path='../../../../linux-80211n-csitool-supplementary/netlink/'
mkdir -p $folder
for loc in `cat $txrxloc_conf`
do
    echo $loc
    param=${room}_${antenna}_${loc}
    sleep $twait
    echo "Start capture at $timestamp"
    f_path="${folder}/csi_${param}.dat"
    echo $f_path
    sudo ${logging_bin_path}log_to_file $f_path &
    PID=$!
    sleep $interval
    kill -INT $PID
    echo "Finish capture at $(date +"%T") for param: $param "
done
echo "finish testing at "$(date +"%T")
