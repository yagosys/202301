#!/bin/bash -xe
filename="./../02_modifygkevmipforwarding.sh"
doc_ext="gen.sh"
echo -e '- enable worker node ipforwarding\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"

by default, the GKE come with ipforwarding disabled. for cFOS to work. we have to enable ip forwarding on worker node. for more detail, check https://github.com/GoogleCloudPlatform/guest-configs/blob/master/src/etc/sysctl.d/60-gce-network-security.conf for ipv4 forwarding config 

to enable ipforwarding, we need to config *canIpForward: true* for instance profile, for more detail , check  https://cloud.google.com/vpc/docs/using-routes#canipforward.

EOF

echo -e '- paste below command to enable ipforwarding\n ' >> "${filename}.md" 


echo -e '```' >> "${filename}.md"
cat $filename.$doc_ext >> "${filename}.md"
echo -e '```' >> "${filename}.md"






