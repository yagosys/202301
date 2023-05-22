#!/bin/bash 
[[ $internet_webf_url == "" ]] && internet_webf_url="https://xoso.com.vn"
[[ -z $cfos_label ]] && cfos_label="fos"
policy_id="101"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $internet_webf_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=$policy_id  ; done
