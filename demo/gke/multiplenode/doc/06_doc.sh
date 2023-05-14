#!/bin/bash
filename="./../06_create_app_deployment_multitool.sh"

echo '- create demo application deployment' > "${filename}.md"

cat << EOF >> "${filename}.md"

we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp" } ]'* to config to POD for secondary interface and custom route entry.
we did not touch pod default route, instead we only insert custom route that we are interested. so for destination, the next hop will be cFOS. cFOS will inspect traffic for those traffic.
we configured ip address 1.1.1.1/32 , 89.238.73.0/24 , 104.18.0.0/16 route point to cFOS for inspection in this demo. 

EOF

echo '- paste below command to create application deployment' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl rollout status deployment multitool01-deployment"

echo "\`$command\`" >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$($command)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


command='kubectl get pod -l app=multitool01'
echo "\`$command\`" >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$($command)"  >> "${filename}.md"
echo '```' >> "${filename}.md"

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/\$podName -- ip route && kubectl exec -t po/\$podName -- ip address ; done" 
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"

