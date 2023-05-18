[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"
nodeList=$(kubectl get pod -l app=$cfos_label -o jsonpath='{.items[*].status.podIP}')
kubectl delete cm foscfgfirewallpolicy
echo $nodeList
for i in $nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/$configmap_policy_id"
}
done
