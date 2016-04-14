barrierloc_conf='conf/barrierloc'
btype_conf='conf/barriertype'
gw=192.168.1.1
# tx_power= 200mW, tx_rate=default
# antenna relative posture: para, orth
antenna=para
# Room status: empty, barrier 
room=barrier
#btype=metal
timestamp=$(date +"%T")
interval=60
twait=20
echo "start testing at $timestamp"
folder='data/case2'
logging_bin_path='../../../../linux-80211n-csitool-supplementary/netlink/'
mkdir -p $folder
for btype in `cat $btype_conf`
do
    for loc in `cat $barrierloc_conf`
    do
        echo $loc
        param=${room}_${antenna}_${btype}_${loc}
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
done
echo "finish testing at "$(date +"%T")
