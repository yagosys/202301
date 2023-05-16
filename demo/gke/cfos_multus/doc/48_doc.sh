#!/bin/bash
filename="./../48_deploy_constraint_fos_cfos.sh"

echo '- install policy constraint   ' > "${filename}.md"

cat << EOF >> "${filename}.md"

the policy constraint mainly function as parameter input to constraint template. here for example, use pass in policy id=200 for constraint template. we also pass in cFOS restAPI URL etc., 
beaware that here we are using dns name of clusterIP for cFOS API, if we are not using shared  storage for cFOS /data folder, we need run API call multiple times to make sure it config each of cFOS POD. 

EOF

echo '- paste below command to install policy constraint template ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"

command="kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml"

echo 'check routing table and ip address' >> "${filename}.md"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"


