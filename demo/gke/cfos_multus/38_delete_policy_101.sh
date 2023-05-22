[[ -z $1 ]] && policy_id="101" || policy_id=$1
echo delete policyid $policy_id
[[ -z $cfos_label ]] && cfos_label="fos"
#url="http://$cfos_label-deployment.default.svc.cluster.local"
nodeList=$(kubectl get pod -l app=$cfos_label -o jsonpath='{.items[*].status.podIP}')
#kubectl delete cm foscfgfirewallpolicy
echo $nodeList
for i in $nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/$policy_id"
}
done
