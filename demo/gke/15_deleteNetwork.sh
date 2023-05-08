[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"
[[ $ipcidrRange == "" ]] && ipcidrRange="10.0.0.0/24"
[[ $firewallruleName == "" ]] && firewallruleName="$networkName-allow-custom"
[[ $firewallallowProtocol == "" ]] && firewallallowProtocol="tcp:22"

gcloud compute firewall-rules delete $firewallruleName 
gcloud compute networks subnets delete $subnetName && \
gcloud compute networks delete $networkName  

