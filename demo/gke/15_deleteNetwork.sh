networkName="$1"
subnetName="$2"
ipcidrRange="$3"
firewallruleName="$4"

[[ "$1" == "" ]] && networkName="gkenetwork" 
[[ "$2" == "" ]] && subnetName="gkenode" 
[[ "$3" == "" ]] && ipcidrRange="10.0.0.0/24" 
[[ "$4" == "" ]] && firewallruleName="$networkName-allow-custom" 

gcloud compute firewall-rules delete $firewallruleName 
gcloud compute networks subnets delete $subnetName && \
gcloud compute networks delete $networkName  

