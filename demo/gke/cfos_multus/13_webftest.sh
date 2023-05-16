#!/bin/bash
[[ $webf_target_url == "" ]] && webf_target_url="https://www.eicar.org/download/eicar.com.txt"
echo -e 'generate traffic to $webf_target_url' 

kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 300 ; done
