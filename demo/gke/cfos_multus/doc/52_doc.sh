#!/bin/bash
filename="./../52_ipstest.sh"

echo '- do a ips test on a target website' > "${filename}.md"

cat << EOF >> "${filename}.md"
we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is 200
EOF

echo '- paste below command to send malicous traffic from application pod ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl get pod | grep fos | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/ips.0 | grep policyid=200 ; done"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

