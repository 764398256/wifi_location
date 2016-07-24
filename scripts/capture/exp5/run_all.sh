workers='workerfile'
log_file='~/projects/linux-80211n-csitool-supplementary/netlink/log_to_file'
datapath='~/projects/wifi_location/scripts/capture/exp5/data/'
timestamp=$(date +"%T")
echo "Start capture at $timestamp"
while IFS='' read -r -u10 fd || [[ -n "$fd" ]]; do
   username=$(echo ${fd} | cut -d' ' -f1) 
   addr=$(echo ${fd} | cut -d' ' -f2)
   echo "${username} at ${addr}"
   ssh  ${username}@${addr} "mkdir -p $datapath"
   ssh  ${username}@${addr} screen -d -m -S Ping "sudo ping -i 0.1 192.168.1.1 &"
   ssh  ${username}@${addr} screen -d -m -S Log "sudo ${log_file} ${datapath}$1"
done 10< "$workers"
