#!/bin/bash
filename="./../24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh"

echo -e '- modify worker node default CNI config\n' > "${filename}.md"

cat << EOF >> "${filename}.md"

in previous section, we did not touch application POD's default route, only we interested destination like 1.1.1.1 is send to cFOS, the rest of traffic will contine go to internet via default route, what about if want send all traffic from application POD to cFOS ,to doing this,
we will need then insert a default route into application pod, for this purpose, we will need use add annotation with keyword default-route to the POD definition. but this is not enough. as you still want some other traffic continue to go to default interface instead goes to cFOS, for example, the traffic goes to gke cluster IP and cross POD to POD traffic. the GKE default cni come with host-local ipam, inside host-local ipam , we can insert custom route, we added clusterIP CIDR range and POD IP CIDR range, after that, restart multus DaemonSet to update Multus default config .

EOF

echo -e '- paste below command to modify default GKE cni config to insert route \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl logs ds/kube-multus-ds -n kube-system"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

