[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"

url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=$gatekeeper_policy_id  ; done
