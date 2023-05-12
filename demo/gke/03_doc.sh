#!/bin/bash
filename="03_install_multus.sh"

echo '- install multus cni ' > "${filename}.md"

cat << EOF >> "${filename}.md"

We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, we need to use filename that alphabetally less than 10 to take priority. here we use *07-multus.conf* which will become the default cni. inside *07-multus.conf* config. we added two specific route which ask POD CIDR subnet and CLUSTER VIP subnet continue to use cluster default network instead of send traffic to cFOS with bridge CNI. 
we also need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission

EOF

echo '- paste below command to install multus CNI with manual config ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


echo '`kubectl rollout status ds/kube-multus-ds -n kube-system`' >> "${filename}.md"
echo '```' >> "${filename}.md"
echo "$(kubectl rollout status ds/kube-multus-ds -n kube-system)"  >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- you can also ssh into worker node to check more detail'  >> "${filename}.md"


echo '- paste below command to check more detail on workder node  ' >> "${filename}.md" 

filename1="03_optional_check_ssh_gke_worker.sh" 
echo '```' >> "${filename}.md"
cat $filename1 >> "${filename}.md"
echo '```' >> "${filename}.md"
