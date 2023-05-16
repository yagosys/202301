#!/bin/bash
filename="./../46_install_gatekeeperv3.sh"

echo '- install gatekeeperv3 ' > "${filename}.md"

cat << EOF >> "${filename}.md"
We will use standard k8s networkpolicy to create firewallpolicy for cFOS, the networkpolicy submitted by kubectl will first be send to gatekeeper admission controller. where there is a constraint delpoyed to inspect the policy constraint via constraint template. if the networkpolicy pass the constrait check. the constraint template will use cFOS Restapi to create firewall policy. and then the constraint template will give output telling the networkpolicy creation is forbiden instead it created on CFOS. 

EOF

echo '- paste below command to install gatekeeper ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"

command="kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system &&  \
kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system  && kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system"

echo 'check routing table and ip address' >> "${filename}.md"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"


