#!/bin/bash
filename="10_config_cfos_staticroute.sh"

echo '- create configmap for cfos to config static route ' > "${filename}.md"

cat << EOF >> "${filename}.md"
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS for static route
the static route created by cFOS by default is in route table 231. 


EOF

echo '- paste below command to create configmap that include static route ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"



command='kubectl get configmap foscfgstaticroute -o yaml'

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


echo 'check cfos static routing table'  >> "${filename}.md"
command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$nodeName\" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/\$podName -- ip route show table 231"

echo 'check routing table and ip address' >> "${filename}.md"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"
