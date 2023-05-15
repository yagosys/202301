#!/bin/bash 
clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) && \
namelist=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" ) && \
for name in $namelist ; do {

route_exists=$(gcloud compute ssh $name --command="sudo grep -E '\"dst\": \"10.144.0.0\\/20\"|\"dst\": \"10.140.0.0\\/14\"' /etc/cni/net.d/10-containerd-net.conflist")
if [ -z "$route_exists" ]; then
  gcloud compute ssh $name --command="sudo sed -i '/\"dst\": \"0.0.0.0\\/0\"/!b;n;N;s/        \\]$/,\n          {\"dst\": \"10.144.0.0\\/20\"},\n          {\"dst\": \"10.140.0.0\\/14\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"
kubectl rollout restart ds/kube-multus-ds -n kube-system && 
kubectl rollout status ds/kube-multus-ds -n kube-system 
kubectl logs  ds/kube-multus-ds -n kube-system
fi


 #gcloud compute ssh $name --command="sudo sed -i '/\"dst\": \"0.0.0.0\\/0\"/!b;n;N;s/        \\]$/,\n          {\"dst\": \"10.144.0.0\\/20\"},\n          {\"dst\": \"10.140.0.0\\/14\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"


#gcloud compute ssh $name --command="sudo cat /etc/cni/net.d/10-containerd-net.conflist"
#gcloud compute ssh $name --command='sudo cat /etc/cni/net.d/00-multus.conf' 
kubectl logs  ds/kube-multus-ds -n kube-system
}
done
