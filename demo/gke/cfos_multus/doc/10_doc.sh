#!/bin/bash
filename="./../10_config_cfos_firewallpolicy.sh"

echo '- create configmap for cfos to get firewall policy configuration ' > "${filename}.md"

cat << EOF >> "${filename}.md"
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS
there is an issue in this version, the configuration applied via configmap will not take effect until you restart cFOS DS.
the firewall policy has policy id set to 300 and source address set to any

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

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; kubectl logs po/\$podName ; done"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"
