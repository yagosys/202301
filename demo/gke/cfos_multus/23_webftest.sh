[[ -z $cfos_label ]] && cfos_label="fos"
#[[ -z $1 ]] &&  webf_target_url="https://www.eicar.org/download/eicar.com.txt" || webf_target_url=$1
[[ $webf_target_url == "" ]] && webf_target_url="https://www.casino.org"
policy_id="101"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=$policy_id  ; done
