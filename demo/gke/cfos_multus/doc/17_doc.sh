#!/bin/bash
filename="./../17_delete_policy_300.sh"

echo -e '- use cfos restful API to delete firewall policy \n' > "${filename}.md"

cat << EOF >> "${filename}.md"
we can use cFOS shell to change firewall policy, we can also use cFOS restAPI to do the same. 
after delete firewall policy, ping to 1.1.1.1 from application pod will no longer reachable
EOF

echo -e '- paste below command delete firewall policy \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"

command="kubectl get pod | grep multi | grep -v termin  | awk '{print \$1}'  | while read line; do echo -e pod \$line; kubectl exec -t po/\$line -- ping -c1 1.1.1.1 ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

