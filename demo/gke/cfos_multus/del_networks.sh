#!/bin/bash

[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"
[[ $ipcidrRange == "" ]] && ipcidrRange="10.0.0.0/24"
[[ $firewallruleName == "" ]] && firewallruleName="$networkName-allow-custom"
[[ $firewallallowProtocol == "" ]] && firewallallowProtocol="tcp:22"

echo $networkName
gcloud compute firewall-rules delete $firewallruleName  -q
gcloud compute networks subnets delete $subnetName -q && \
gcloud compute networks delete $networkName -q  

