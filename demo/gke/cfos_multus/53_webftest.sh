[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"
[[ -z $1 ]] &&  webf_target_url="https://www.eicar.org/download/eicar.com.txt" || webf_target_url=$1
echo $webf_target_url
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=$gatekeeper_policy_id  ; done
