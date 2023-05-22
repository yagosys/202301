#!/bin/bash
[[ $webf_target_url == "" ]] && webf_target_url="https://www.eicar.org/download/eicar.com.txt"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"

[[ -z $cfos_label ]] && cfos_label="fos"
echo -e 'generate traffic to $webf_target_url' 

kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=$configmap_policy_id ; done
