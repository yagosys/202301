#!/bin/bash
filename="./../01_gke.sh"

echo '- create gke cluster ' > "${filename}.md"

cat << EOF >> "${filename}.md"

create gke cluster 
*enable-ip-alias* to enable use alias ip on VM for pod ip address
*service-ipv4-cidr* is for clusterVIP address
*cluster-ipv4-cidr* is for POD ip address scope

EOF

echo '- paste below command to create gke cluster ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


echo '`kubectl get node -o wide`' >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$(kubectl get node -o wide)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


