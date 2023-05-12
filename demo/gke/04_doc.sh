#!/bin/bash
filename="04_create_nad.sh"

echo '- install multus cni ' > "${filename}.md"

cat << EOF >> "${filename}.md"
We will create net-attach-def with bridge CNI ,multus CNI will use this net-attach-def to create bridge network and attach POD to the network.
We use host-local as IPAM CNI.

EOF

echo '- paste below command to create net-attach-def' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl get net-attach-def"

echo "\`$command\`" >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$($command)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


