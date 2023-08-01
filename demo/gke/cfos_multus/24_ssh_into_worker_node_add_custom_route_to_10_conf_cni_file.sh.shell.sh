#!/bin/bash -x 

[[ $services_ipv4_cidr == "" ]] && services_ipv4_cidr="10.144.0.0/20"
[[ $cluster_ipv4_cidr == "" ]] && cluster_ipv4_cidr="10.140.0.0/14"

services_ip=${services_ipv4_cidr%%/*}
services_netmask=${services_ipv4_cidr#*/}

pod_ip=${cluster_ipv4_cidr%%/*}
pod_netmask=${cluster_ipv4_cidr#*/}

filename="24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh.shell.sh.gen.sh"
cat << EOF > $filename

clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) 
namelist=\$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" ) 
for name in \$namelist ; do {

route_exists=\$(gcloud compute ssh \$name --command="sudo grep -E '\"dst\": \"$services_ip\\/$services_netmask\"|\"dst\": \"$pod_ip\\/$pod_netmask\"' /etc/cni/net.d/10-containerd-net.conflist")

if [ -z "\$route_exists" ]; then
  gcloud compute ssh \$name --command="sudo sed -i '/\"dst\": \"0.0.0.0\\/0\"/!b;n;N;s/        \\]$/,\n          {\"dst\": \"$services_ip\\/$services_netmask\"},\n          {\"dst\": \"$pod_ip\\/$pod_netmask\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"
kubectl rollout restart ds/kube-multus-ds -n kube-system && 
kubectl rollout status ds/kube-multus-ds -n kube-system 
kubectl logs  ds/kube-multus-ds -n kube-system
fi


kubectl logs  ds/kube-multus-ds -n kube-system
}
done
EOF
chmod +x $filename
./$filename
