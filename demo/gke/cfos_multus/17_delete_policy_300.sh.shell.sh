[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"
filename="17_delete_policy_300.sh.shell.sh.gen.sh"
cat << EOF > $filename
nodeList=\$(kubectl get pod -l app=$cfos_label -o jsonpath='{.items[*].status.podIP}')
kubectl delete cm foscfgfirewallpolicy
echo \$nodeList
apppodname=\$(kubectl get pod | grep multi | grep -v termin  | awk '{print \$1}' | head -1)
for i in \$nodeList; do {
kubectl exec -it po/\$apppodname -- curl -X DELETE "\$i/api/v2/cmdb/firewall/policy/$configmap_policy_id"
}
done
EOF
chmod +x $filename
./$filename
