#!/bin/bash
[[ $ips_target_url == "" ]] && ips_target_url="www.hackthebox.eu"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"
[[ -z $cfos_label ]] && cfos_label="fos"
filename="12_ipstest.sh.shell.sh.gen.sh"
cat << EOF > $filename
echo -e 'generate traffic to $ips_target_url' 
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- dig $ips_target_url ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- ping -c 2  $ips_target_url ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$ips_target_url ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/ips.0 | grep $configmap_policy_id ; done
EOF
chmod +x $filename
./$filename
