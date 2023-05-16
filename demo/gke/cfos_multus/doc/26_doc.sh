#!/bin/bash
filename="./../26_create_app_deployment_multtool_with_defaultroute.sh"

echo '- create application deployment ' > "${filename}.md"

cat << EOF >> "${filename}.md"

create deployment with annotation to use net-attach-def and also config default route point to net-attach-def attached interface. which is cFOS interface. 
the annotation field has context 
*k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp",  "default-route": ["10.1.200.252"]  } ]'* , which config an default route with nexthop to 10.1.200.252.
check ip route table on application shall see the default route point to cFOS interface. 
EOF

echo '- paste below command to create deployment ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/\$podName -- ip route && kubectl exec -t po/\$podName -- ip address ; done" 

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

