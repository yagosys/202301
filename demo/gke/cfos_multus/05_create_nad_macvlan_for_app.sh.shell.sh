#!/bin/bash 
filename="05_create_nad_macvlan_for_app.sh.shell.sh.yml.sh"
[[ $cfosIpshort == "" ]] && cfosIpshort="10.1.200.252" 
[[ $custom_dst1 == "" ]] && custom_dst1='{ "dst": "104.18.0.0/16", "gw": "'$cfosIpshort'" },'
[[ $custom_dst2 == "" ]] && custom_dst2='{ "dst": "89.238.73.97/32", "gw": "'$cfosIpshort'"},'
[[ $custom_dst3 == "" ]] && custom_dst3='{ "dst": "172.67.162.8/32", "gw": "'$cfosIpshort'"},'
[[ $custom_dst4 == "" ]] && custom_dst4='{ "dst": "104.21.42.126/32","gw": "'$cfosIpshort'"},'
[[ $custom_dst5 == "" ]] && custom_dst5='{ "dst": "104.17.0.0/16","gw": "'$cfosIpshort'"},'
[[ $custom_lastdst == "" ]] && custom_lastdst='{ "dst": "1.1.1.1/32", "gw": "'$cfosIpshort'"}'
[[ $app_nad_annotation == "" ]] && app_nad_annotation="cfosapp"
[[ $master_interface_on_worker_node == "" ]] && master_interface_on_worker_node="ens4"

number_of_custom_dst=5
result=""
for i in $(seq 1 $number_of_custom_dst); do
    temp="custom_dst$i"
    result+=$'\n'"${!temp}"
done
echo -e "$result"

cat << OUTER_EOF > $filename
cat << EOF | kubectl create -f  -
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
kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def $app_nad_annotation -o yaml
OUTER_EOF
chmod +x $filename
./$filename
