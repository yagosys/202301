#!/bin/bash -xe
filename="04_nad_macvlan_for_app.yml"
[[ custom_dst1 == "" ]] && custom_dst1='{ "dst": "1.1.1.1/32", "gw": "10.1.200.252" },'
[[ custom_dst2 == "" ]] && custom_dst2='{ "dst": "104.18.0.0/16", "gw": "10.1.200.252"},'
[[ custom_lastdst == "" ]] && custom_lastdst='{ "dst": "89.238.73.0/24", "gw": "10.1.200.252"}'
[[ app_nad_annotation == "" ]] && app_nad_annotation="cfosapp"

cat << EOF > $filename
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: $app_nad_annotation
spec:
  config: '{
      "cniVersion": "0.3.1",
      "type": "macvlan",
      "master": "$master_interface_on_worker_node",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "routes": [
          $custom_dst1
          $custom_dst2
          $custom_lastdst
        ],
        "rangeStart": "10.1.200.20",
        "rangeEnd": "10.1.200.251",
        "gateway": "10.1.200.1"
      }
    }'
EOF
kubectl create -f $filename && kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def $app_nad_annotation -o yaml

