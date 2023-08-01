[[ -z $cfos_label ]] && cfos_label="fos"
[[ $webf_target_url == "" ]] && webf_target_url="https://www.casino.org"
policy_id="101"
filename="23_webftest.sh.shell.sh.gen.sh"
cat << EOF > $filename
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep policyid=$policy_id  ; done
EOF
chmod +x $filename
./$filename
