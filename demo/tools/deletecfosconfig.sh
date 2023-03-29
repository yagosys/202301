cfospod=$(kubectl get pods -l app=fos -o json | jq -r '.items[].metadata.name' | tr '\n' ' ')
read -ra CFOSPOD <<< "$cfospod"
for pod in "${CFOSPOD[@]}"; do
	echo remove address,addgrp, policy config on $pod
	kubectl exec -it po/$pod -- rm /data/cmdb/config/firewall/address.json
	kubectl exec -it po/$pod -- rm /data/cmdb/config/firewall/addrgrp.json
	kubectl exec -it po/$pod -- rm /data/cmdb/config/firewall/policy.json
done
