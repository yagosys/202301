#!/bin/bash
filename="./../04_create_nad_for_cfos.sh"

echo '- create net-attach-def for cfos  ' > "${filename}.md"

cat << EOF >> "${filename}.md"
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for cfos to attach. 
the cni config of macvlan use bridge mode and associated with "ens4" interface on worker node. if the master interface on worker node is other than ens4. you need change that.
you can ssh into worker node to check master interface name. 
the net-attach-def has name "cfosdefaultcni5". 
EOF

echo '- paste below command to create net-attach-def' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl get net-attach-def cfosdefaultcni5 -o yaml "

echo "\`$command\`" >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$($command)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


