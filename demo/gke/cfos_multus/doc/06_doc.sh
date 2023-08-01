#!/bin/bash
filename="./../06_create_app_deployment_multitool.sh"
[[ -z $app_deployment_label ]] && app_deployment_label="multitool01"

echo -e '- create demo application deployment\n' > "${filename}.md"

cat << EOF >> "${filename}.md"

we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "$app_nad_annotation" } ]'* to config to POD for secondary interface and custom route entry.
we did not touch pod default route, instead we only insert custom route that we are interested. so for destination, the next hop will be cFOS. cFOS will inspect traffic for those traffic.
when POD attach to *$app_nad_annotation*, it will obtain *$custom_dst1, $custom_dst2, $custom_lastdst*  route point to cFOS for inspection in this demo. 

EOF

echo -e '- paste below command to create application deployment\n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl rollout status deployment $app_deployment_label-deployment"

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"


command="kubectl get pod -l app=$app_deployment_label"
echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=$app_deployment_label --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/\$podName -- ip route && kubectl exec -t po/\$podName -- ip address ; done" 
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"

