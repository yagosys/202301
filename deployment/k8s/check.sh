file_path="/home/ubuntu/deploymentcompleted"
log_file="/var/log/user-data.log"

while [ ! -f $file_path ]; do
  tail -n -5 $log_file 
  sleep 3 
done
