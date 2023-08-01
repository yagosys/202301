[[ -z $1 ]] && policy_id="101" || policy_id=$1
echo delete policyid $policy_id
[[ -z $cfos_label ]] && cfos_label="fos"
filename="38_delete_policy_101.sh.shell.sh.gen.sh"
cat << EOF > $filename
nodeList=\$(kubectl get pod -l app=$cfos_label -o jsonpath='{.items[*].status.podIP}')
for i in \$nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "\$i/api/v2/cmdb/firewall/policy/$policy_id"
}
done
EOF
chmod +x $filename
./$filename
