for pid in $(ps aux | grep 'SCREEN' | awk '{print $2}')
do
    sudo pkill -TERM -P $pid
done
