gcloud compute ssh ubuntu@abm-ws --command "mkdir -p /home/ubuntu/.kube"
gcloud compute ssh ubuntu@abm-ws --command "cp /home/ubuntu/bmctl-workspace/wandycluster/wandycluster-kubeconfig /home/ubuntu/.kube/config"
gcloud compute ssh ubuntu@abm-ws --command "kubectl get pod -A"
gcloud compute ssh ubuntu@abm-ws --command "kubectl taint nodes abm-admin-cluster-cp  node-role.kubernetes.io/control-plane:NoSchedule-"
