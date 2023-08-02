#!/bin/bash
filename="./../05_create_nad_macvlan_for_app.sh.shell.sh.yml.sh"
source ./../variable.sh
echo -e '- create net-attach-def for application deployment  ' > "${filename}.md"

cat << EOF >> "${filename}.md"
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for application to attach. 
the cni config of macvlan use bridge mode and associated with *"$master_interface_on_worker_node"* interface on worker node. if the master interface on worker node is other than $master_interface_on_worker_node. you need change that.
you can ssh into worker node to check master interface name. 
the net-attach-def has name *"$app_nad_annotation"*.  we also use *"$app_nad_annotation"* as label in policy manager demo. if you change this name to something  else, you will also need to change the image for policy manager where *$app_nad_annotation* is hard coded in the image script. 
in the nad config, we inserted specific custom route *$custom_dst1,$custom_dst2,$custom_lastdst*, for traffic destinated to these subnets, the nexthop is cFOS interface ip.
EOF


echo -e '- paste below command to create net-attach-def\n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get net-attach-def $app_nad_annotation -o yaml "

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"


