policy_id="300"
kubectl exec -it po/policymanager -- curl -X DELETE "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy/$policy_id"
