#!/bin/bash
filename="00_create_network.sh"

echo '- create network for gke cluster ' > "${filename}.md"

cat << EOF >> "${filename}.md"

create network for GKE VM instances.
the *ipcidrRange* is the ip range for VM node. 
the *firewallallowProtocol="tcp:22* allow ssh into worker node from anywhere 
EOF

echo '- paste below command to create network ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


echo '`gcloud compute networks list --format json`' >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$(gcloud compute networks list --format json)" >> "${filename}.md"
echo '```' >> "${filename}.md"

echo '`gcloud compute networks subnets list --format json`' >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$(gcloud compute networks subnets list --format json)" >> "${filename}.md"
echo '```' >> "${filename}.md"

echo '`gcloud compute firewall-rules list --format json`' >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$(gcloud compute firewall-rules list --format json)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


