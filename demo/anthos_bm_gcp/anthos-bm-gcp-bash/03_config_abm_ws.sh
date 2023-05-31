#!/bin/bash -xe
gcloud compute ssh root@"abm-ws"  << EOF
mkdir -p /root/.kube
cp /root/bmctl-workspace/wandycluster/wandycluster-kubeconfig /root/.kube/config
echo \"alias k=kubectl\" >> /root/.bashrc
git clone https://github.com/yagosys/202301.git
kubectl taint nodes abm-admin-cluster-cp node-role.kubernetes.io/master:NoSchedule-
mkdir -p /license

EOF

