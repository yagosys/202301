#!/bin/bash
filename="./../38_delete_policy_101.sh"
policy_id="101"

echo -e '- use cfos restful API to delete firewall policy\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"
the policy created by policy_manager pod has policy id $policy_id, let us delete this firewall policy use cfosrestapi. 
after delete firewall policy, we use crl to check whether any firewall policy left on cFOS POD
EOF

echo -e '- paste below command delete firewall policy\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"



command="kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy/$policy_id"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '\n' >> "${filename}.md"
echo -e '```' >> "${filename}.md"

