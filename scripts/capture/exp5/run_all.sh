workers='workerfile'
log_file='~/projects/linux-80211n-csitool-supplementary/netlink/log_to_file'
datapath='~/projects/wifi_location/scripts/'
for fd in `cat ${workerfile}`
do
   username=$(echo ${fd} | cut -d' ' -f1) 
   addr=$(echo ${fd} | cut -d' ' -f2)
   ssh ${username}@${addr} '${log_file} $1'
done
