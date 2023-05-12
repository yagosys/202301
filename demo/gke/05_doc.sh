#!/bin/bash
filename="05_create_app_deployment.sh"

echo '- create demo application deployment' > "${filename}.md"

cat << EOF >> "${filename}.md"

we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'* to config to POD to use default route point to CFOS.

the pod shall have an additional interface attached to bridge network created by nad and POD 's default route shall point to cFOS.

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

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=\$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName=\"\$nodeName\" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/\$podName -- ip route && kubectl exec -t po/\$podName -- ip address"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"


