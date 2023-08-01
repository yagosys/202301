#!/bin/bash
#[[ $webf_target_url == "" ]] && webf_target_url="https://www.eicar.org/download/eicar.com.txt"
[[ $webf_target_url == "" ]] && webf_target_url="https://www.casino.org"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"

[[ -z $cfos_label ]] && cfos_label="fos"
filename="13_webftest.sh.shell.sh.gen.sh"
cat << EOF > $filename
echo -e 'generate traffic to $webf_target_url' 

kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep policyid=$configmap_policy_id ; done
EOF
chmod +x $filename
./$filename
