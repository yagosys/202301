#!/bin/bash
filename="./../24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh"

echo '- modify worker node default CNI confige' > "${filename}.md"

cat << EOF >> "${filename}.md"

in previous section, we did not touch application POD's default route, only we interested destination like 1.1.1.1 is send to cFOS, what about if want send all traffic from application POD to cFOS, \
we will need then insert a default route into application pod, for this purpose, we will need use keyword default-route in the annotation part of POD definition. but this is not enough. as you still want some other traffic continue to go to default interface instead goes to cFOS, for example, the traffic goes to gke cluster IP and cross POD to POD traffic. so also need modify the default GKE cni config to insert custom route. 

EOF

echo '- paste below command to modify default GKE cni config to insert route ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl logs ds/kube-multus-ds -n kube-system"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

