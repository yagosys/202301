#!/bin/bash 
filename="05_nad_macvlan_for_app.yaml"

[[ $cfosIpshort == "" ]] && cfosIpshort="10.1.200.252" 
[[ $custom_dst1 == "" ]] && custom_dst1='{ "dst": "1.1.1.1/32", "gw": "$cfosIpshort" },'
[[ $custom_dst2 == "" ]] && custom_dst2='{ "dst": "104.18.0.0/16", "gw": "$cfosIpshort"},'
[[ $custom_lastdst == "" ]] && custom_lastdst='{ "dst": "1.1.1.1/32", "gw": "$cfosIpshort"}'
[[ $app_nad_annotation == "" ]] && app_nad_annotation="cfosapp"

number_of_custom_dst=$(env | grep custom_dst | cut -d '=' -f 1 | wc -l)

result=""
for i in $(seq 1 $number_of_custom_dst); do
    temp="custom_dst$i"
    result+=$'\n'"${!temp}"
done

echo -e "$result"


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
        "subnet": "${cfosIpshort%.*}.0/24",
        "routes": [
         $result
         $custom_lastdst
        ],
        "rangeStart": "${cfosIpshort%.*}.20",
        "rangeEnd": "${cfosIpshort%.*}.251",
        "gateway": "${cfosIpshort%.*}.1"
      }
    }'
EOF
kubectl create -f $filename && kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def $app_nad_annotation -o yaml

