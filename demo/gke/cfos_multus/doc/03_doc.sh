#!/bin/bash
filename="./../03_install_multus_auto.sh"

echo -e '- install multus cni \n' > "${filename}.md"

cat << EOF >> "${filename}.md"


We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, 
the default multus config will use *"--multus-conf-file=auto"*, with this option. multus will automatically create 00-multus.conf file with delegate to default 10-containerd-net.conflist. in this demo. we use default behavior. 
we  need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission.
each worker node will have one multus POD installed. 
EOF

echo -e '- paste below command to install multus CNI  ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


echo -e '`kubectl rollout status ds/kube-multus-ds -n kube-system`' >> "${filename}.md"
echo -e '`kubectl logs ds/kube-multus-ds -c kube-multus -n kube-system)`' >> "${filename}.md" 
echo -e ' you shall see output ' >> "${filename}.md" 
echo -e '```' >> "${filename}.md"
echo -e "$(kubectl rollout status ds/kube-multus-ds -n kube-system)"  >> "${filename}.md"

echo -e "$(kubectl logs ds/kube-multus-ds -c kube-multus -n kube-system)" >> "${filename}.md"
echo -e '```' >> "${filename}.md"


