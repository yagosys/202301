#!/bin/bash
filename="./../01_gke.sh"

echo -e '- create gke cluster\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"

*enable-ip-alias* to enable use alias ip on VM for pod ip address
*service-ipv4-cidr* is the cidr for clusterVIP address
*cluster-ipv4-cidr* is for POD ip address scope
*kubectl get node -o wide" shall show the node in ready state. 

EOF

echo -e '- paste below command to create gke cluster\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


echo -e '`kubectl get node -o wide`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$(kubectl get node -o wide)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"


