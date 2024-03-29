#!/bin/bash
[[ $networkName == "" ]] && networkName="gkenetwork"
gkeNetworkName=$(gcloud compute networks list --format="value(name)" --filter="name="$networkName""  --limit=1)
source ./../variable.sh
filename="./../00_create_network.sh"
doc_ext="gen.sh"

echo -e  '- create network for gke cluster ' > "${filename}.md"

cat << EOF >> "${filename}.md"

create network for GKE VM instances.
the *ipcidrRange* is the ip range for VM node. 
the *firewallallowProtocol=$firewallallowProtocol* allow ssh into worker node from anywhere  to *$firewallallowProtocol* protocols
EOF

echo -e  '- paste below command to create network, subnets and firewall-rules  ' >> "${filename}.md" 

echo -e  '```' >> "${filename}.md"
cat $filename.$doc_ext >> "${filename}.md"
echo -e  '```' >> "${filename}.md"


echo -e  '- check the result\n' >> "${filename}.md"


echo -e  '```' >> "${filename}.md"
echo -e  'gcloud compute networks list ' >> "${filename}.md"
echo -e  '```' >> "${filename}.md"

echo -e  '```' >> "${filename}.md"
echo -e  "$(gcloud compute networks list )" >> "${filename}.md"
echo -e  '```' >> "${filename}.md"


echo -e  '```' >> "${filename}.md"
echo -e  'gcloud compute networks subnets list ' >> "${filename}.md"
echo -e  '```' >> "${filename}.md"

echo -e  '```' >> "${filename}.md"
echo -e  "$(gcloud compute networks subnets list --network $gkeNetworkName)" >> "${filename}.md"
echo -e  '```' >> "${filename}.md"

echo -e  '```' >> "${filename}.md"
echo -e  'gcloud compute firewall-rules list ' >> "${filename}.md"
echo -e  '```' >> "${filename}.md"

echo -e  '```' >> "${filename}.md"
echo -e  "$(gcloud compute firewall-rules list )"  >> "${filename}.md"
echo -e  '```' >> "${filename}.md"


