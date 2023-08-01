[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"
[[ -z $webf_target_url ]] && webf_target_url="https://www.casino.org"
echo $webf_target_url
filename="53_webftest.sh.shell.sh.gen.sh"

cat << EOF > $filename
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line --  curl -k -I  $webf_target_url  ; done
kubectl get pod | grep $cfos_label | awk '{print $1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep policyid=$gatekeeper_policy_id  ; done
EOF
chmod +x $filename
./$filename
