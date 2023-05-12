#!/bin/bash
filename="09_config_cfos_firewallpolicy.sh"

echo '- create configmap for cfos to get configuration ' > "${filename}.md"

cat << EOF >> "${filename}.md"
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS

EOF

echo '- paste below command to create configmap that include firewall policy configuration' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"



command='kubectl get configmap foscfgfirewallpolicy -o yaml'

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"




echo 'check cfos log for retrive config from configmap' >> "${filename}.md"
command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$nodeName\" -o jsonpath='{.items[*].metadata.name}') && kubectl logs po/\$podName"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"
