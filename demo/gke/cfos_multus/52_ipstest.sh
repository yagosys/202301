#!/bin/bash
[[ -z $1 ]] && ips_target_url="www.hackthebox.eu" || ips_target_url=$1
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"
[[ -z $cfos_label ]] && cfos_label="fos"
echo -e 'generate traffic to $ips_target_url' 
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- dig $ips_target_url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c 2  $ips_target_url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$ips_target_url ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=$gatekeeper_policy_id ; done
