#!/bin/bash
filename="./../49_deploy_network_firewall_policy_egress.sh"

echo '- create standard networkpolicy   ' > "${filename}.md"

cat << EOF >> "${filename}.md"
here we create reguard k8s egress networkpolicy, this policy will be created on cFOS with gatekeeper help. 
after creating. use "kubectl get networkpolicy will not show you the policy" as it actually created on cFOS. 
instead , you can get policy by use cFOS API with command *kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy*
EOF

echo '- paste below command to deploy networkpolicy ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"

command="kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy && kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"

echo '```' >> "${filename}.md"


