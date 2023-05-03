networkName="gkenetwork" && \
subnetName="gkenode" && \
ipcidrRange="10.0.0.0/24" && \
firewallruleName="$networkName-allow-custom" && \

gcloud compute networks create $networkName --subnet-mode custom --bgp-routing-mode  regional 

gcloud compute networks subnets create $subnetName --network=$networkName --range=$ipcidrRange &&  \
gcloud compute firewall-rules create $firewallruleName --network $networkName --allow all --direction ingress --priority 65534  #&& \

#gcloud services enable container.googleapis.com 
