#!/bin/bash
filename="./../11_cfos_ds_restart.sh"

echo -e '- restart cfos DaemonSet  to workaround policy not work issue\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"
when use configmap to apply firewallpolicy to cFOS, if it's the first time to config cFOS using firewall policy, then a restart cFOS is required. alternatively, you can shell into cFOS then run *fcnsh* to enter cFOS shell and remove config and added back as a workaroud. 

EOF

echo -e '- paste below command to restart cFOS DaemonSet\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


echo -e '- check deployment status of cFOS\n' >> "${filename}.md"
command='kubectl rollout status ds/fos-deployment'
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

echo -e 'check cfos iptables entry\n'  >> "${filename}.md"

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; echo \$podName\n;  kubectl exec -it po/\$podName -- iptables -L -t nat --verbose | grep MASQ ; done" 

echo -e 'check routing table and ip address\n' >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"

echo -e 'check ping result\n' >> "${filename}.md" 

command="kubectl get pod | grep multi | grep -v termin  | awk '{print \$1}'  | while read line; do echo pod \$line; kubectl exec -t po/\$line -- ping -c1 1.1.1.1 ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"

