#!/bin/bash -xe
echo $networkName

[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"
[[ $ipcidrRange == "" ]] && ipcidrRange="10.0.0.0/24"
[[ $firewallruleName == "" ]] && firewallruleName="$networkName-allow-custom"
[[ $firewallallowProtocol == "" ]] && firewallallowProtocol="tcp:22"
 
echo $networkName
gcloud compute networks create $networkName --subnet-mode custom --bgp-routing-mode  regional 
gcloud compute networks subnets create $subnetName --network=$networkName --range=$ipcidrRange &&  \
gcloud compute firewall-rules create $firewallruleName --network $networkName --allow $firewallallowProtocol --direction ingress --priority 65534  

[ { "creationTimestamp": "2023-05-11T19:20:51.505-07:00", "fingerprint": "nReRZj_3uIc=", "gatewayAddress": "10.0.0.1", "id": "8178195609685073004", "ipCidrRange": "10.0.0.0/24", "kind": "compute#subnetwork", "name": "gkenode", "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1", "privateIpGoogleAccess": false, "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS", "purpose": "PRIVATE", "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1", "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1/subnetworks/gkenode", "stackType": "IPV4_ONLY" } ]
