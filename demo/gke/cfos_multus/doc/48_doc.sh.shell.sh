#!/bin/bash
filename="./../48_deploy_constraint_fos_cfos.sh.shell.sh.yml.sh"

echo -e '- install policy constraint\n   ' > "${filename}.md"

cat << EOF >> "${filename}.md"

the policy constraint define what API to watch, for example, here we wathc NetworkPolicy API, also it  function as parameter input to constraint template. here for example, user pass in policy id=200 for constraint template. we also pass in cFOS restAPI URL etc., 
beaware that here we are using dns name of clusterIP for cFOS API, if we are not using shared  storage for cFOS /data folder, we need run API call multiple times to make sure it config each of cFOS POD. 

EOF

echo -e '- paste below command to install policy constraint template \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"

command="kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml"

echo -e 'check constraint\n ' >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"


