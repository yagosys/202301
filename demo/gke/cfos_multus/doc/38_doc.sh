#!/bin/bash
filename="./../38_delete_policy_101.sh"

echo '- use cfos restful API to delete firewall policy ' > "${filename}.md"

cat << EOF >> "${filename}.md"
the policy created by policy_manager pod has policy id 101, let us delete this firewall policy use cfosrestapi. 
after delete firewall policy, we use crl to check whether any firewall policy left on cFOS POD
EOF

echo '- paste below command delete firewall policy ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"



command="kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

