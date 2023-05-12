#!/bin/bash
filename="02_modifygkevmipforwarding.sh"

echo '- enable worker node ipforwarding ' > "${filename}.md"

cat << EOF >> "${filename}.md"

by default, the GKE come with ipforwarding disabled. for cFOS to work. we have to enable ip forwarding on worker node.
to enable ipforwarding, we need to config *canIpForward: true* for instance profile, for more detail , check  https://cloud.google.com/vpc/docs/using-routes#canipforward.

EOF

echo '- paste below command to enable ipforwarding ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"






