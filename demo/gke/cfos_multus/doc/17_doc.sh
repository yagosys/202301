#!/bin/bash
filename="./../17_delete_policy_300.sh"

echo '- use cfos restful API to delete firewall policy ' > "${filename}.md"

cat << EOF >> "${filename}.md"
we can use cFOS shell to change firewall policy, we can also use cFOS restAPI to do the same. 
after delete firewall policy, ping to 1.1.1.1 from application pod will no longer reachable
EOF

echo '- paste below command delete firewall policy ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"

command="kubectl get pod | grep multi | grep -v termin  | awk '{print \$1}'  | while read line; do echo pod \$line; kubectl exec -t po/\$line -- ping -c1 1.1.1.1 ; done"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

