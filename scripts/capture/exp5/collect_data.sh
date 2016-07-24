workers='workerfile'
log_file='~/projects/linux-80211n-csitool-supplementary/netlink/log_to_file'
datapath='~/projects/wifi_location/scripts/capture/exp5/data/'
data_repo='data/'
while IFS='' read -r -u10 fd || [[ -n "$fd" ]]; do
   username=$(echo ${fd} | cut -d' ' -f1) 
   addr=$(echo ${fd} | cut -d' ' -f2)
   echo "${username} at ${addr}"
   mkdir -p $data_repo$addr
   scp  ${username}@${addr}:${datapath}* $data_repo$addr
done 10< "$workers"
