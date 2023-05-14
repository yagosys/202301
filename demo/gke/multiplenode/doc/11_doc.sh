#!/bin/bash
filename="./../11_cfos_ds_restart.sh"

echo '- restart cfos DaemonSet  to workaround policy not work issue ' > "${filename}.md"

cat << EOF >> "${filename}.md"
when use configmap to apply firewallpolicy to cFOS, if it's the first time to config cFOS using firewall policy, then a restart cFOS is required


EOF

echo '- paste below command to restart cFOS DaemonSet ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


echo '- check deployment status of cFOS' >> "${filename}.md"
command='kubectl rollout status ds/fos-deployment'
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

echo 'check cfos iptables entry'  >> "${filename}.md"

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ;  kubectl exec -it po/\$podName -- iptables -L -t nat --verbose | grep MASQ ; done" 

echo 'check routing table and ip address' >> "${filename}.md"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"
