#!/bin/bash
filename="./../04_create_nad_for_cfos.sh"

echo -e '- create net-attach-def for cfos  \n' > "${filename}.md"

cat << EOF >> "${filename}.md"
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for cfos to attach. 
the cni config of macvlan use bridge mode and associated with $master_interface_on_worker_node   interface on worker node. if the master interface on worker node is other than $master_interface_on_worker_node. you need change that to match the actual one on the host node 
you can ssh into worker node to check master interface name. 
the net-attach-def has name $net_attach_def_name_for_cfos
EOF

echo -e '- paste below command to create net-attach-def\n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get net-attach-def $net_attach_def_name_for_cfos -o yaml "

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"
