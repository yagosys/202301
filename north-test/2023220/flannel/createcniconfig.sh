#!/bin/bash
#create a directory to place cni configuration for multus daemonSet
#this directory is defaul to /etc/cni/multus/net.d
#cni config in this directory does not accept plugins field, so plugins chain is not supported 
#10.96 is the cluster service default network
#set isGateway allow to assign ip to cni5 bridge interface. the default ip of last field is 1. so the default ip is 10.86.0.1
#the ranges/subnet decide which subnet to use for pod that attached to this subnet
#this cni config is prepared for net-attach-def to use. referenced by same name, cfosdefaultcni5 here. 
##{
#    "cniVersion": "0.3.1",
#    "name": "cfosdefaultcni5",
#       "type": "bridge",
#       "bridge": "cni5",
#       "isGateway": true,
#       "ipMasq": true,
#       "hairpinMode": true,
#       "ipam": {
#           "type": "host-local",
#           "routes": [
#               { "dst": "10.96.0.0/12","gw": "10.86.0.1" },
#               { "dst": "10.0.0.2/32", "gw": "10.86.0.1" }
#           ],
#           "ranges": [
#               [{ "subnet": "10.86.0.0/16" }]
#           ]
#       }
#}
#apiVersion: "k8s.cni.cncf.io/v1"
#kind: NetworkAttachmentDefinition
#metadata:
#  name: cfosdefaultcni5
#

# Set the variables
if [ -f /run/systemd/resolve/resolv.conf ]; then
  dnsserver=$(grep nameserver /run/systemd/resolve/resolv.conf | awk '{print $2}')
else
  dnsserver=8.8.8.8
fi
serviceSubnet=$(kubectl get cm kubeadm-config -n kube-system -o yaml | grep serviceSubnet | awk '{print $2}')
podsubnet="10.86.0"
# Set the directory path
directory="/etc/cni/multus/net.d/"

# Create the directory if it doesn't exist
if [ ! -d "$directory" ]; then
  sudo mkdir -p "$directory"
fi

# Set the file path
file="$directory/cfosdefaultcni5.conf"

# Create the file with the specified content
cat << EOF  | sudo tee "$file"
{
    "cniVersion": "0.3.1",
    "name": "cfosdefaultcni5",
    "type": "bridge",
    "bridge": "cni5",
    "isGateway": true,
    "ipMasq": true,
    "hairpinMode": true,
    "ipam": {
        "type": "host-local",
        "routes": [
            { "dst": "$serviceSubnet","gw": "$podsubnet.1" },
            { "dst": "$dnsserver/32", "gw": "$podsubnet.1" }
        ],
        "ranges": [
            [{ "subnet": "$podsubnet.0/16" }]
        ]
    }
}
EOF
echo placed above under $directory
