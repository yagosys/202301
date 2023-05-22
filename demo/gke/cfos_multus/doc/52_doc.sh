#!/bin/bash
[[ -z $cfos_label ]] && cfos_label="fos"
filename="./../52_ipstest.sh"

policy_id=200

echo -e '- do a ips test on a target website\n' > "${filename}.md"

cat << EOF >> "${filename}.md"
we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is $policy_id
EOF

echo -e '- paste below command to send malicous traffic from application pod\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod | grep $cfos_label | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/ips.0 | grep policyid=$policy_id ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

