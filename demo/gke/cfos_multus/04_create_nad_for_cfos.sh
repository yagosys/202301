#!/bin/bash -xe
[[ $master_interface_on_worker_node == "" ]] && master_interface_on_worker_node="ens4"
[[ $net_attach_def_name_for_cfos == "" ]]    &&  net_attach_def_name_for_cfos="cfosdefaultcni5"
filename="04_nad_macvlan_cfos.yml"
cat << EOF > $filename
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: $net_attach_def_name_for_cfos
spec:
  config: '{
      "cniVersion": "0.3.1",
      "type": "macvlan",
      "master": "$master_interface_on_worker_node",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "rangeStart": "10.1.200.250",
        "rangeEnd": "10.1.200.253",
        "gateway": "10.1.200.1"
      }
    }'
EOF
kubectl create -f $filename && kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def cfosdefaultcni5 -o yaml


