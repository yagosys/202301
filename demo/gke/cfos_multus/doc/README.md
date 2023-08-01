README
cat ./../00_create_network.sh.md


- create network for gke cluster 

create network for GKE VM instances.
the *ipcidrRange* is the ip range for VM node. 
the *firewallallowProtocol=all* allow ssh into worker node from anywhere  to *all* protocols
- paste below command to create network, subnets and firewall-rules  
```
gcloud compute networks create gkenetwork --subnet-mode custom --bgp-routing-mode  regional 
gcloud compute networks subnets create gkenode --network=gkenetwork --range=10.0.0.0/24 &&  gcloud compute firewall-rules create gkenetwork-allow-custom --network gkenetwork --allow all --direction ingress --priority  100 
```
- check the result

`gcloud compute networks list --format json`
```
[
  {
    "autoCreateSubnetworks": true,
    "creationTimestamp": "2023-05-21T20:13:52.000-07:00",
    "id": "2969526282620461824",
    "kind": "compute#network",
    "name": "default",
    "networkFirewallPolicyEnforcementOrder": "AFTER_CLASSIC_FIREWALL",
    "routingConfig": {
      "routingMode": "REGIONAL"
    },
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "selfLinkWithId": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/2969526282620461824",
    "subnetworks": [
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west6/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-south1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-central1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east7/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-west1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east4/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-west1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west12/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-central2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west4/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-southwest1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-north1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-central1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-east1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west8/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east5/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west10/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east2/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west4/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west3/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west9/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast3/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1/subnetworks/default",
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west3/subnetworks/default"
    ],
    "x_gcloud_bgp_routing_mode": "REGIONAL",
    "x_gcloud_subnet_mode": "AUTO"
  },
  {
    "autoCreateSubnetworks": false,
    "creationTimestamp": "2023-08-01T04:09:45.160-07:00",
    "id": "5173971891427563798",
    "kind": "compute#network",
    "name": "gkenetwork",
    "networkFirewallPolicyEnforcementOrder": "AFTER_CLASSIC_FIREWALL",
    "routingConfig": {
      "routingMode": "REGIONAL"
    },
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork",
    "selfLinkWithId": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/5173971891427563798",
    "subnetworks": [
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1/subnetworks/gkenode"
    ],
    "x_gcloud_bgp_routing_mode": "REGIONAL",
    "x_gcloud_subnet_mode": "CUSTOM"
  }
]
```
`gcloud compute networks subnets list --format json`
```
[
  {
    "creationTimestamp": "2023-05-21T20:14:01.952-07:00",
    "fingerprint": "DBvUAB5JpnM=",
    "gatewayAddress": "10.128.0.1",
    "id": "3653023482570564374",
    "ipCidrRange": "10.128.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-central1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-central1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.104-07:00",
    "fingerprint": "F8LwyqDEWfE=",
    "gatewayAddress": "10.132.0.1",
    "id": "5531467510110970645",
    "ipCidrRange": "10.132.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.212-07:00",
    "fingerprint": "kWhgapVphBg=",
    "gatewayAddress": "10.138.0.1",
    "id": "1354424154744906517",
    "ipCidrRange": "10.138.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.597-07:00",
    "fingerprint": "fw7EZ1Nthsc=",
    "gatewayAddress": "10.140.0.1",
    "id": "3452618813890585364",
    "ipCidrRange": "10.140.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-08-01T04:10:01.698-07:00",
    "fingerprint": "7j1CK8BiEEo=",
    "gatewayAddress": "10.0.0.1",
    "id": "4820830154112980710",
    "ipCidrRange": "10.0.0.0/24",
    "kind": "compute#subnetwork",
    "name": "gkenode",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1/subnetworks/gkenode",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.243-07:00",
    "fingerprint": "_5_z-gQgM5s=",
    "gatewayAddress": "10.142.0.1",
    "id": "8374742504377377557",
    "ipCidrRange": "10.142.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.365-07:00",
    "fingerprint": "UeUfquoHGn0=",
    "gatewayAddress": "10.146.0.1",
    "id": "8198574688336044821",
    "ipCidrRange": "10.146.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:04.363-07:00",
    "fingerprint": "KbUuUGtm4UI=",
    "gatewayAddress": "10.148.0.1",
    "id": "486222762403652371",
    "ipCidrRange": "10.148.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.209-07:00",
    "fingerprint": "09fY46MCKhE=",
    "gatewayAddress": "10.150.0.1",
    "id": "1923220159951495957",
    "ipCidrRange": "10.150.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east4",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east4/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:04.729-07:00",
    "fingerprint": "qxkbwZ9o4QQ=",
    "gatewayAddress": "10.152.0.1",
    "id": "1229029036895200019",
    "ipCidrRange": "10.152.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.961-07:00",
    "fingerprint": "tnb69KSqvzA=",
    "gatewayAddress": "10.154.0.1",
    "id": "5858556564218536725",
    "ipCidrRange": "10.154.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.072-07:00",
    "fingerprint": "EhpweTastXE=",
    "gatewayAddress": "10.156.0.1",
    "id": "2088568579712049940",
    "ipCidrRange": "10.156.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west3",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west3/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.624-07:00",
    "fingerprint": "Jt0-3NtDFf0=",
    "gatewayAddress": "10.158.0.1",
    "id": "8298213110649938708",
    "ipCidrRange": "10.158.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-east1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-east1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:04.143-07:00",
    "fingerprint": "F3B6y9-blEA=",
    "gatewayAddress": "10.160.0.1",
    "id": "7483311257429697299",
    "ipCidrRange": "10.160.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.413-07:00",
    "fingerprint": "Ma5_jrNNt1w=",
    "gatewayAddress": "10.162.0.1",
    "id": "1381506058144932629",
    "ipCidrRange": "10.162.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.097-07:00",
    "fingerprint": "dSI9jbHxgb8=",
    "gatewayAddress": "10.164.0.1",
    "id": "8425078284135916308",
    "ipCidrRange": "10.164.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west4",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west4/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.348-07:00",
    "fingerprint": "0_hzXv23VBE=",
    "gatewayAddress": "10.166.0.1",
    "id": "4657576810815906580",
    "ipCidrRange": "10.166.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-north1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-north1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.913-07:00",
    "fingerprint": "JWvyvc7cynI=",
    "gatewayAddress": "10.168.0.1",
    "id": "7449269969411859221",
    "ipCidrRange": "10.168.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.733-07:00",
    "fingerprint": "yc-ha1-gLyg=",
    "gatewayAddress": "10.170.0.1",
    "id": "7361961479081779988",
    "ipCidrRange": "10.170.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.172-07:00",
    "fingerprint": "_GiHXAagrGE=",
    "gatewayAddress": "10.172.0.1",
    "id": "6540204067783140116",
    "ipCidrRange": "10.172.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west6",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west6/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.559-07:00",
    "fingerprint": "6wkfI5Ku9eM=",
    "gatewayAddress": "10.174.0.1",
    "id": "72994733265740564",
    "ipCidrRange": "10.174.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.207-07:00",
    "fingerprint": "F3-Is16syts=",
    "gatewayAddress": "10.178.0.1",
    "id": "816096634651239188",
    "ipCidrRange": "10.178.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast3",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-northeast3/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.253-07:00",
    "fingerprint": "EauVXNI1Fmw=",
    "gatewayAddress": "10.180.0.1",
    "id": "7203855658377503509",
    "ipCidrRange": "10.180.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west3",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west3/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.740-07:00",
    "fingerprint": "pe_8H5OxcOs=",
    "gatewayAddress": "10.182.0.1",
    "id": "9137734403605619477",
    "ipCidrRange": "10.182.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west4",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west4/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.854-07:00",
    "fingerprint": "3ReVp6pLIaM=",
    "gatewayAddress": "10.184.0.1",
    "id": "4110360190183236372",
    "ipCidrRange": "10.184.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-southeast2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.220-07:00",
    "fingerprint": "TH_TKIw-bhs=",
    "gatewayAddress": "10.186.0.1",
    "id": "8958960105056330517",
    "ipCidrRange": "10.186.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-central2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-central2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.319-07:00",
    "fingerprint": "ok2oL2vbTE8=",
    "gatewayAddress": "10.188.0.1",
    "id": "7958282353435435797",
    "ipCidrRange": "10.188.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/northamerica-northeast2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:05.031-07:00",
    "fingerprint": "QtGIc7qImbU=",
    "gatewayAddress": "10.190.0.1",
    "id": "8361679060698882834",
    "ipCidrRange": "10.190.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-south2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:04.229-07:00",
    "fingerprint": "pEq5WGnsWV8=",
    "gatewayAddress": "10.192.0.1",
    "id": "2954054461800538899",
    "ipCidrRange": "10.192.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast2",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/australia-southeast2/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.814-07:00",
    "fingerprint": "wqr-2daA42U=",
    "gatewayAddress": "10.194.0.1",
    "id": "1706741906878718740",
    "ipCidrRange": "10.194.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-west1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/southamerica-west1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-22T11:32:08.804-07:00",
    "fingerprint": "X6rdudQq5eM=",
    "gatewayAddress": "10.196.0.1",
    "id": "3894697366716287943",
    "ipCidrRange": "10.196.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east7",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east7/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.783-07:00",
    "fingerprint": "AFipPZLhx4o=",
    "gatewayAddress": "10.198.0.1",
    "id": "1608699481527116565",
    "ipCidrRange": "10.198.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west8",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west8/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.179-07:00",
    "fingerprint": "tX8SHj2p22g=",
    "gatewayAddress": "10.200.0.1",
    "id": "7078781632282845973",
    "ipCidrRange": "10.200.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west9",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west9/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.281-07:00",
    "fingerprint": "IZ-gDdKtV7w=",
    "gatewayAddress": "10.202.0.1",
    "id": "993042883450200853",
    "ipCidrRange": "10.202.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east5",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-east5/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.679-07:00",
    "fingerprint": "ar-Zcgn0ejQ=",
    "gatewayAddress": "10.204.0.1",
    "id": "8581268502181536533",
    "ipCidrRange": "10.204.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-southwest1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-southwest1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.102-07:00",
    "fingerprint": "ZuIhWEGo_1o=",
    "gatewayAddress": "10.206.0.1",
    "id": "5893132846247666453",
    "ipCidrRange": "10.206.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-south1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-south1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.032-07:00",
    "fingerprint": "eb-zD2AdsG4=",
    "gatewayAddress": "10.208.0.1",
    "id": "4719216308842357524",
    "ipCidrRange": "10.208.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-west1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-west1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:02.790-07:00",
    "fingerprint": "eibcnlYr0fU=",
    "gatewayAddress": "10.210.0.1",
    "id": "2489464168605246229",
    "ipCidrRange": "10.210.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west12",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west12/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-05-21T20:14:03.574-07:00",
    "fingerprint": "rATX5jeFgV8=",
    "gatewayAddress": "10.212.0.1",
    "id": "2906688982639665940",
    "ipCidrRange": "10.212.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-central1",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/me-central1/subnetworks/default",
    "stackType": "IPV4_ONLY"
  },
  {
    "creationTimestamp": "2023-07-01T16:18:47.044-07:00",
    "fingerprint": "YmZ42G6z3Pc=",
    "gatewayAddress": "10.214.0.1",
    "id": "5634814039672294072",
    "ipCidrRange": "10.214.0.0/20",
    "kind": "compute#subnetwork",
    "name": "default",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "privateIpGoogleAccess": false,
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west10",
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/europe-west10/subnetworks/default",
    "stackType": "IPV4_ONLY"
  }
]
```
`gcloud compute firewall-rules list --format json`
```
[
  {
    "allowed": [
      {
        "IPProtocol": "all"
      }
    ],
    "creationTimestamp": "2023-05-21T20:15:39.366-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "5858433534880342196",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "defaultall",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/default",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/defaultall",
    "sourceRanges": [
      "0.0.0.0/0"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "all"
      }
    ],
    "creationTimestamp": "2023-08-01T04:10:20.802-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "6597635391206282995",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gkenetwork-allow-custom",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork",
    "priority": 100,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gkenetwork-allow-custom",
    "sourceRanges": [
      "0.0.0.0/0"
    ]
  }
]
```
end of ./../00_create_network.sh.md


cat ./../01_gke.sh.md


- create gke cluster
 

*enable-ip-alias* to enable use alias ip on VM for pod ip address
*service-ipv4-cidr* is the cidr for clusterVIP address
*cluster-ipv4-cidr* is for POD ip address scope
*kubectl get node -o wide" shall show the node in ready state. 

- paste below command to create gke cluster
 
```
projectName=$(gcloud config list --format="value(core.project)")
region=$(gcloud config get compute/region)

gcloud services enable container.googleapis.com  && 
gcloud container clusters create my-first-cluster-1  	--no-enable-basic-auth 	--cluster-version 1.26.5-gke.1400 	--release-channel "stable" 	--machine-type e2-standard-2 	--image-type "UBUNTU_CONTAINERD" 	--disk-type "pd-balanced" 	--disk-size "32" 	--metadata disable-legacy-endpoints=true 	--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" 	--max-pods-per-node "110" 	--num-nodes 2 	--enable-ip-alias 	--network "projects//global/networks/gkenetwork" 	--subnetwork "projects//regions//subnetworks/gkenode"        	--no-enable-intra-node-visibility 	--default-max-pods-per-node "110" 	--no-enable-master-authorized-networks 	--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver 	--enable-autoupgrade 	--enable-autorepair        	--max-surge-upgrade 1 	--max-unavailable-upgrade 0 	--enable-shielded-nodes 	--services-ipv4-cidr 10.144.0.0/20         --cluster-ipv4-cidr  10.140.0.0/14
```
- check the result

`kubectl get node -o wide`
```
NAME                                                STATUS   ROLES    AGE   VERSION            INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
gke-my-first-cluster-1-default-pool-9dde0662-5880   Ready    <none>   38s   v1.26.5-gke.1400   10.0.0.4      35.189.170.110   Ubuntu 22.04.2 LTS   5.15.0-1033-gke   containerd://1.6.18
gke-my-first-cluster-1-default-pool-9dde0662-m4b0   Ready    <none>   39s   v1.26.5-gke.1400   10.0.0.3      34.81.140.4      Ubuntu 22.04.2 LTS   5.15.0-1033-gke   containerd://1.6.18
```
end of ./../01_gke.sh.md


cat ./../02_modifygkevmipforwarding.sh.md


- enable worker node ipforwarding
 

by default, the GKE come with ipforwarding disabled. for cFOS to work. we have to enable ip forwarding on worker node. for more detail, check https://github.com/GoogleCloudPlatform/guest-configs/blob/master/src/etc/sysctl.d/60-gce-network-security.conf for ipv4 forwarding config 

to enable ipforwarding, we need to config *canIpForward: true* for instance profile, for more detail , check  https://cloud.google.com/vpc/docs/using-routes#canipforward.

- paste below command to enable ipforwarding
 
```
node_list=$(gcloud compute instances list --filter="name~'my-first-cluster-1'"  --format="value(name)" )
for name in $node_list; do {

gcloud compute instances export $name     --project cfos-384323     --zone asia-east1-a     --destination=./$name.txt
grep -q "canIpForward: true" $name.txt || sed -i '/networkInterfaces/i canIpForward: true' $name.txt
sed '/networkInterfaces/i canIpForward: true' $name.txt 
gcloud compute instances update-from-file $name    --project cfos-384323     --zone asia-east1-a     --source=$name.txt     --most-disruptive-allowed-action=REFRESH
echo "done for $name"
}
done
```
end of ./../02_modifygkevmipforwarding.sh.md


cat ./../03_install_multus_auto.sh.md


- install multus cni 



We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, 
the default multus config will use *"--multus-conf-file=auto"*, with this option. multus will automatically create 00-multus.conf file with delegate to default 10-containerd-net.conflist. in this demo. we use default behavior. 
we  need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission.
each worker node will have one multus POD installed. 
- paste below command to install multus CNI  
```
file="multus_auto.yml"
multusconfig="auto"
multus_bin_hostpath="/home/kubernetes/bin"
cat << EOF > $file
# Note:
#   This deployment file is designed for 'quickstart' of multus, easy installation to test it,
#   hence this deployment yaml does not care about following things intentionally.
#     - various configuration options
#     - minor deployment scenario
#     - upgrade/update/uninstall scenario
#   Multus team understand users deployment scenarios are diverse, hence we do not cover
#   comprehensive deployment scenario. We expect that it is covered by each platform deployment.
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: network-attachment-definitions.k8s.cni.cncf.io
spec:
  group: k8s.cni.cncf.io
  scope: Namespaced
  names:
    plural: network-attachment-definitions
    singular: network-attachment-definition
    kind: NetworkAttachmentDefinition
    shortNames:
    - net-attach-def
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          description: 'NetworkAttachmentDefinition is a CRD schema specified by the Network Plumbing
            Working Group to express the intent for attaching pods to one or more logical or physical
            networks. More information available at: https://github.com/k8snetworkplumbingwg/multi-net-spec'
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this represen
                tation of an object. Servers should convert recognized schemas to the
                latest internal value, and may reject unrecognized values. More info:
                https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this
                object represents. Servers may infer this from the endpoint the client
                submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: 'NetworkAttachmentDefinition spec defines the desired state of a network attachment'
              type: object
              properties:
                config:
                  description: 'NetworkAttachmentDefinition config is a JSON-formatted CNI configuration'
                  type: string
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: multus
rules:
  - apiGroups: ["k8s.cni.cncf.io"]
    resources:
      - '*'
    verbs:
      - '*'
  - apiGroups:
      - ""
    resources:
      - pods
      - pods/status
    verbs:
      - get
      - update
  - apiGroups:
      - ""
      - events.k8s.io
    resources:
      - events
    verbs:
      - create
      - patch
      - update
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: multus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: multus
subjects:
- kind: ServiceAccount
  name: multus
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: multus
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: multus-cni-config
  namespace: kube-system
  labels:
    tier: node
    app: multus
data:
  # NOTE: If you'd prefer to manually apply a configuration file, you may create one here.
  # In the case you'd like to customize the Multus installation, you should change the arguments to the Multus pod
  # change the "args" line below from
  # - "--multus-conf-file=auto"
  # to:
  # "--multus-conf-file=/tmp/multus-conf/07-multus.conf"
  # Additionally -- you should ensure that the name "07-multus.conf" is the alphabetically first name in the
  # /etc/cni/net.d/ directory on each node, otherwise, it will not be used by the Kubelet.
  cni-conf.json: |
    {
      "name": "multus-cni-network",
      "type": "multus",
      "capabilities": {
        "portMappings": true
      },
      "delegates": [
        {
          "cniVersion": "0.3.1",
          "name": "k8s-pod-network",
          "plugins": [
            {
              "type": "ptp",
              "mtu": 1460,
              "ipam": {
                "type": "host-local",
                "subnet": "10.140.0.0/24",
                "gateway": "10.140.0.1",
                "routes": [
                  {
                    "dst": "10.144.0.0/20"
                  },
                  {
                    "dst": "10.140.0.0/14"
                  },
                  {
                    "dst": "0.0.0.0/0"
                  }
                 ]
            }
          },
              {
                "type": "portmap",
                "capabilities": {
                  "portMappings": true
                }
              }
          ]
        }
      ],
      "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig"
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-multus-ds
  namespace: kube-system
  labels:
    tier: node
    app: multus
    name: multus
spec:
  selector:
    matchLabels:
      name: multus
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        tier: node
        app: multus
        name: multus
    spec:
      hostNetwork: true
      tolerations:
      - operator: Exists
        effect: NoSchedule
      - operator: Exists
        effect: NoExecute
      serviceAccountName: multus
      containers:
      - name: kube-multus
        image: ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
        command: ["/entrypoint.sh"]
        args:
        - "--multus-conf-file=$multusconfig"
        #- "--multus-conf-file=auto"
        - "--cni-version=0.3.1"
        resources:
          requests:
            cpu: "100m"
            memory: "50Mi"
          limits:
            cpu: "100m"
            memory: "50Mi"
        securityContext:
          privileged: true
        volumeMounts:
        - name: cni
          mountPath: /host/etc/cni/net.d
        - name: cnibin
          mountPath: /host/opt/cni/bin
        - name: multus-cfg
          mountPath: /tmp/multus-conf
      initContainers:
        - name: install-multus-binary
          image: ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
          command:
            - "cp"
            - "/usr/src/multus-cni/bin/multus"
            - "/host/opt/cni/bin/multus"
          resources:
            requests:
              cpu: "10m"
              memory: "15Mi"
          securityContext:
            privileged: true
          volumeMounts:
            - name: cnibin
              mountPath: /host/opt/cni/bin
              mountPropagation: Bidirectional
      terminationGracePeriodSeconds: 10
      volumes:
        - name: cni
          hostPath:
            path: /etc/cni/net.d
        - name: cnibin
          hostPath:
            path: $multus_bin_hostpath
        - name: multus-cfg
          configMap:
            name: multus-cni-config
            items:
            - key: cni-conf.json
              path: 07-multus.conf
EOF
kubectl create -f $file
kubectl rollout status ds/kube-multus-ds -n kube-system
```
- check the result

`kubectl rollout status ds/kube-multus-ds -n kube-system`
`kubectl logs ds/kube-multus-ds -c kube-multus -n kube-system)`
 you shall see output 
```
daemon set "kube-multus-ds" successfully rolled out
2023-08-01T11:18:53+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-08-01T11:18:53+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-08-01T11:18:54+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-08-01T11:18:54+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
```
end of ./../03_install_multus_auto.sh.md


cat ./../04_create_nad_for_cfos.sh.shell.sh.yml.sh.md


- create net-attach-def for cfos  

We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for cfos to attach. 
the cni config of macvlan use bridge mode and associated with    interface on worker node. if the master interface on worker node is other than . you need change that to match the actual one on the host node 
you can ssh into worker node to check master interface name. 
the net-attach-def has name 
- paste below command to create net-attach-def

```
cat << EOF | kubectl create -f  -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: cfosdefaultcni5
spec:
  config: '{
      "cniVersion": "0.3.1",
      "type": "macvlan",
      "master": "ens4",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "rangeStart": "10.1.200.251",
        "rangeEnd": "10.1.200.253",
        "gateway": "10.1.200.1"
      }
    }'
EOF

kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def cfosdefaultcni5 -o yaml
```
- check the result

`kubectl get net-attach-def  -o yaml `
```
apiVersion: v1
items:
- apiVersion: k8s.cni.cncf.io/v1
  kind: NetworkAttachmentDefinition
  metadata:
    creationTimestamp: "2023-08-01T11:18:58Z"
    generation: 1
    name: cfosdefaultcni5
    namespace: default
    resourceVersion: "2437"
    uid: e3e24676-cd5c-4061-ad8f-e702ef22800a
  spec:
    config: '{ "cniVersion": "0.3.1", "type": "macvlan", "master": "ens4", "mode":
      "bridge", "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "rangeStart":
      "10.1.200.251", "rangeEnd": "10.1.200.253", "gateway": "10.1.200.1" } }'
kind: List
metadata:
  resourceVersion: ""
```
end of ./../04_create_nad_for_cfos.sh.shell.sh.yml.sh.md


cat ./../05_create_nad_macvlan_for_app.sh.shell.sh.yml.sh.md


- create net-attach-def for application deployment  
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for application to attach. 
the cni config of macvlan use bridge mode and associated with *""* interface on worker node. if the master interface on worker node is other than . you need change that.
you can ssh into worker node to check master interface name. 
the net-attach-def has name *""*.  we also use *""* as label in policy manager demo. if you change this name to something  else, you will also need to change the image for policy manager where ** is hard coded in the image script. 
in the nad config, we inserted specific custom route *,,*, for traffic destinated to these subnets, the nexthop is cFOS interface ip.
- paste below command to create net-attach-def

```
cat << EOF | kubectl create -f  -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: cfosapp
spec:
  config: '{
      "cniVersion": "0.3.1",
      "type": "macvlan",
      "master": "ens4",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "routes": [
         
{ "dst": "104.18.0.0/16", "gw": "10.1.200.252" },
{ "dst": "89.238.73.97/32", "gw": "10.1.200.252"},
{ "dst": "172.67.162.8/32", "gw": "10.1.200.252"},
{ "dst": "104.21.42.126/32","gw": "10.1.200.252"},
{ "dst": "104.17.0.0/16","gw": "10.1.200.252"},
         { "dst": "1.1.1.1/32", "gw": "10.1.200.252"}
        ],
        "rangeStart": "10.1.200.20",
        "rangeEnd": "10.1.200.251",
        "gateway": "10.1.200.1"
      }
    }'
EOF
kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def cfosapp -o yaml
```
- check the result

`kubectl get net-attach-def  -o yaml `
```
apiVersion: v1
items:
- apiVersion: k8s.cni.cncf.io/v1
  kind: NetworkAttachmentDefinition
  metadata:
    creationTimestamp: "2023-08-01T11:19:01Z"
    generation: 1
    name: cfosapp
    namespace: default
    resourceVersion: "2462"
    uid: ade3f4f8-1ac8-4212-b0f4-0236d1045ece
  spec:
    config: |-
      { "cniVersion": "0.3.1", "type": "macvlan", "master": "ens4", "mode": "bridge", "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "routes": [
      { "dst": "104.18.0.0/16", "gw": "10.1.200.252" }, { "dst": "89.238.73.97/32", "gw": "10.1.200.252"}, { "dst": "172.67.162.8/32", "gw": "10.1.200.252"}, { "dst": "104.21.42.126/32","gw": "10.1.200.252"}, { "dst": "104.17.0.0/16","gw": "10.1.200.252"}, { "dst": "1.1.1.1/32", "gw": "10.1.200.252"} ], "rangeStart": "10.1.200.20", "rangeEnd": "10.1.200.251", "gateway": "10.1.200.1" } }
- apiVersion: k8s.cni.cncf.io/v1
  kind: NetworkAttachmentDefinition
  metadata:
    creationTimestamp: "2023-08-01T11:18:58Z"
    generation: 1
    name: cfosdefaultcni5
    namespace: default
    resourceVersion: "2437"
    uid: e3e24676-cd5c-4061-ad8f-e702ef22800a
  spec:
    config: '{ "cniVersion": "0.3.1", "type": "macvlan", "master": "ens4", "mode":
      "bridge", "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "rangeStart":
      "10.1.200.251", "rangeEnd": "10.1.200.253", "gateway": "10.1.200.1" } }'
kind: List
metadata:
  resourceVersion: ""
```
end of ./../05_create_nad_macvlan_for_app.sh.shell.sh.yml.sh.md


cat ./../06_create_app_deployment_multitool.sh.shell.sh.yml.sh.md


- create demo application deployment


we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "" } ]'* to config to POD for secondary interface and custom route entry.
we did not touch pod default route, instead we only insert custom route that we are interested. so for destination, the next hop will be cFOS. cFOS will inspect traffic for those traffic.
when POD attach to **, it will obtain *, , *  route point to cFOS for inspection in this demo. 

- paste below command to create application deployment

```
cat << EOF | kubectl create -f  -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 4
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp" } ]'
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
          #image: praqma/network-multitool
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF
kubectl rollout status deployment multitool01-deployment
```
- check the result

`kubectl rollout status deployment multitool01-deployment`
```
deployment "multitool01-deployment" successfully rolled out
```
`kubectl get pod -l app=multitool01`
```
NAME                                      READY   STATUS    RESTARTS   AGE
multitool01-deployment-7f5bf4b7cd-65svd   1/1     Running   0          8s
multitool01-deployment-7f5bf4b7cd-d9ft9   1/1     Running   0          9s
multitool01-deployment-7f5bf4b7cd-h4mnw   1/1     Running   0          8s
multitool01-deployment-7f5bf4b7cd-l8cdc   1/1     Running   0          8s
```
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.1.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.20 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.5 
10.140.1.1 dev eth0 scope link src 10.140.1.5 
89.238.73.97 via 10.1.200.252 dev net1 
104.17.0.0/16 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
104.21.42.126 via 10.1.200.252 dev net1 
172.67.162.8 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 06:cc:6c:7e:45:42 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.5/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 0e:7a:81:c2:df:ab brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.20/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.0.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.21 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10 
10.140.0.1 dev eth0 scope link src 10.140.0.10 
89.238.73.97 via 10.1.200.252 dev net1 
104.17.0.0/16 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
104.21.42.126 via 10.1.200.252 dev net1 
172.67.162.8 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ba:41:b0:54:fd:2c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.10/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 92:a9:fa:bf:1c:32 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.21/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
end of ./../06_create_app_deployment_multitool.sh.shell.sh.yml.sh.md


cat ./../08_create_cfos_account.sh.md


- create cfos role and service account


cfos will require to read configmap permission to get license and also cfos will require read-secrets permission to get secret to pull cfos image

- paste below command to create cfos role and service account
```
file="cfos_account.yml" 
cat << EOF > $file
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: default
  name: configmap-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "watch", "list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-configmaps
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: configmap-reader
  apiGroup: ""

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
   namespace: default
   name: secrets-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: secrets-reader
  apiGroup: ""
EOF

kubectl create -f $file  
```
- check the result

`
kubectl get rolebinding read-configmaps && kubectl get rolebinding read-secrets -o yaml
`
```
NAME              ROLE                           AGE
read-configmaps   ClusterRole/configmap-reader   1s
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2023-08-01T11:19:25Z"
  name: read-secrets
  namespace: default
  resourceVersion: "2684"
  uid: 4445fe8b-bbb9-4688-af76-12952d391281
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: secrets-reader
subjects:
- kind: ServiceAccount
  name: default
```
end of ./../08_create_cfos_account.sh.md


cat ./../09_create_cfos_ds.sh.shell.sh.yml.sh.md


- create cfos role and service account

We will create cFOS as DaemonSet, so each node will have single cFOS POD.
cFOS will be attached to net-attach-def CRD which was created earlier.
cFOS is configured as a ClusterIP service for restapi port.
cFOS will use annotation to attach to net-attach-def CRD cfosdefaultcni5.
k8s.v1.cni.cncf.io/networks means secondary network.
Default interface inside cFOS is net1.
cFOS will have fixed IP 10.1.200.252/32 which is the range of CRD cni configuration.
cFOS can also have a fixed mac address.
Linux capabilities like NET_ADMIN, SYS_AMDIN, NET_RAW are required for ping, sniff and syslog.
cFOS image will be pulled from Docker Hub with pull secret.

- paste below command to create cfos DaemonSet
```
cat << EOF | kubectl create -f  -
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: fos
  name: fos-deployment
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  #sessionAffinity: ClientIP
  selector:
    app: fos
  type: ClusterIP
---

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fos-deployment
  labels:
      app: fos
spec:
  selector:
    matchLabels:
        app: fos
  template:
    metadata:
      labels:
        app: fos
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
        #k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
    spec:
      containers:
      - name: fos
        image: interbeing/fos:v7231x86
        #image: 732600308177.dkr.ecr.ap-east-1.amazonaws.com/fos:v7231x86
        imagePullPolicy: Always
        securityContext:
          privileged: true
          capabilities:
              add: ["NET_ADMIN","SYS_ADMIN","NET_RAW"]
        ports:
        - name: isakmp
          containerPort: 500
          protocol: UDP
        - name: ipsec-nat-t
          containerPort: 4500
          protocol: UDP
        volumeMounts:
        - mountPath: /data
          name: data-volume
      imagePullSecrets:
      - name: dockerinterbeing
      volumes:
      - name: data-volume
        #persistentVolumeClaim:
          #claimName: filestore-pvc
        hostPath:
          path: /home/kubernetes/cfosdata
          type: DirectoryOrCreate
EOF
kubectl rollout status ds/fos-deployment && kubectl get pod -l app=fos
```
- check the result

`
kubectl rollout status ds/fos-deployment && kubectl get pod -l app=fos
`
```
daemon set "fos-deployment" successfully rolled out
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-k24wq   1/1     Running   0          11s
fos-deployment-zcfhr   1/1     Running   0          11s
```
check routing table and ip address

`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.1.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.7 
10.140.1.1 dev eth0 scope link src 10.140.1.7 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 62:04:59:12:36:a4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.7/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.0.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.11 
10.140.0.1 dev eth0 scope link src 10.140.0.11 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether aa:51:bc:6d:03:c3 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.11/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
check cfos license

`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ;  kubectl logs po/$podName ; done
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/08/01 11:19:37 importing license...
INFO: 2023/08/01 11:19:37 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-08-01_11:19:38.00465 ok: run: /run/fcn_service/certd: (pid 275) 1s, normally down
2023-08-01_11:19:43.08419 INFO: 2023/08/01 11:19:43 received a new fos configmap
2023-08-01_11:19:43.08429 INFO: 2023/08/01 11:19:43 configmap name: fos-license, labels: map[app:fos category:license]
2023-08-01_11:19:43.08431 INFO: 2023/08/01 11:19:43 got a fos license

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/08/01 11:19:37 importing license...
INFO: 2023/08/01 11:19:37 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-08-01_11:19:38.07205 ok: run: /run/fcn_service/certd: (pid 273) 1s, normally down
2023-08-01_11:19:43.14212 INFO: 2023/08/01 11:19:43 received a new fos configmap
2023-08-01_11:19:43.14213 INFO: 2023/08/01 11:19:43 configmap name: fos-license, labels: map[app:fos category:license]
2023-08-01_11:19:43.14217 INFO: 2023/08/01 11:19:43 got a fos license
```
end of ./../09_create_cfos_ds.sh.shell.sh.yml.sh.md


cat ./../10_config_cfos_firewallpolicy.sh.shell.sh.yml.sh.md


- create configmap for cfos to get firewall policy configuration/n 
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS
there is an issue in this version, the configuration applied via configmap will not take effect until you restart cFOS DS.
the firewall policy has policy id set to  and source address set to any. once configmap created, cFOS will read the configmap and apply the policy. you can chech the log on cFOS to verify this.
delete configmap will not delete the policy on cFOS. you can also edit the policy in configmap use *kubectl edit cm foscfgfirewallpolicy* to update the policy.

- paste below command to create configmap that include firewall policy configuration/n
```
cat << EOF | kubectl create -f  -
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgfirewallpolicy
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config firewall policy
           edit "300"
               set utm-status enable
               set name "pod_to_internet_HTTPS_HTTP"
               set srcintf any
               set dstintf eth0
               set srcaddr all
               set dstaddr all
               set service HTTPS HTTP PING DNS
               set ssl-ssh-profile "deep-inspection"
               set ips-sensor "default"
               set webfilter-profile "default"
               set av-profile "default"
               set nat enable
               set logtraffic all
           next
       end
EOF
kubectl get cm foscfgfirewallpolicy -o yaml 
```
- check the result

`
kubectl get configmap foscfgfirewallpolicy -o yaml
`
```
apiVersion: v1
data:
  config: |-
    config firewall policy
           edit "300"
               set utm-status enable
               set name "pod_to_internet_HTTPS_HTTP"
               set srcintf any
               set dstintf eth0
               set srcaddr all
               set dstaddr all
               set service HTTPS HTTP PING DNS
               set ssl-ssh-profile "deep-inspection"
               set ips-sensor "default"
               set webfilter-profile "default"
               set av-profile "default"
               set nat enable
               set logtraffic all
           next
       end
  type: partial
kind: ConfigMap
metadata:
  creationTimestamp: "2023-08-01T11:19:49Z"
  labels:
    app: fos
    category: config
  name: foscfgfirewallpolicy
  namespace: default
  resourceVersion: "2901"
  uid: 6a76ba26-eb55-4e09-a54f-d1f2294202f8
```
check cfos log for retrive config from configmap
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl logs po/$podName ; done
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/08/01 11:19:37 importing license...
INFO: 2023/08/01 11:19:37 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-08-01_11:19:38.00465 ok: run: /run/fcn_service/certd: (pid 275) 1s, normally down
2023-08-01_11:19:43.08419 INFO: 2023/08/01 11:19:43 received a new fos configmap
2023-08-01_11:19:43.08429 INFO: 2023/08/01 11:19:43 configmap name: fos-license, labels: map[app:fos category:license]
2023-08-01_11:19:43.08431 INFO: 2023/08/01 11:19:43 got a fos license
2023-08-01_11:19:49.59211 INFO: 2023/08/01 11:19:49 received a new fos configmap
2023-08-01_11:19:49.59212 INFO: 2023/08/01 11:19:49 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-08-01_11:19:49.59212 INFO: 2023/08/01 11:19:49 got a fos config
2023-08-01_11:19:49.59233 INFO: 2023/08/01 11:19:49 applying a partial fos config...
2023-08-01_11:19:49.95481 INFO: 2023/08/01 11:19:49 fos config is applied successfully.

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/08/01 11:19:37 importing license...
INFO: 2023/08/01 11:19:37 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-08-01_11:19:38.07205 ok: run: /run/fcn_service/certd: (pid 273) 1s, normally down
2023-08-01_11:19:43.14212 INFO: 2023/08/01 11:19:43 received a new fos configmap
2023-08-01_11:19:43.14213 INFO: 2023/08/01 11:19:43 configmap name: fos-license, labels: map[app:fos category:license]
2023-08-01_11:19:43.14217 INFO: 2023/08/01 11:19:43 got a fos license
2023-08-01_11:19:49.58671 INFO: 2023/08/01 11:19:49 received a new fos configmap
2023-08-01_11:19:49.58672 INFO: 2023/08/01 11:19:49 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-08-01_11:19:49.58672 INFO: 2023/08/01 11:19:49 got a fos config
2023-08-01_11:19:49.58701 INFO: 2023/08/01 11:19:49 applying a partial fos config...
2023-08-01_11:19:49.98550 INFO: 2023/08/01 11:19:49 fos config is applied successfully.
```
end of ./../10_config_cfos_firewallpolicy.sh.shell.sh.yml.sh.md


cat ./../11_cfos_ds_restart.sh.shell.sh.gen.sh.md


- restart cfos DaemonSet  to workaround policy not work issue
 
when use configmap to apply firewallpolicy to cFOS, if it's the first time to config cFOS using firewall policy, then a restart cFOS is required. alternatively, you can shell into cFOS then run *fcnsh* to enter cFOS shell and remove config and added back as a workaroud. 

- paste below command to restart cFOS DaemonSet
 
```
kubectl rollout status ds/fos-deployment && kubectl rollout restart ds/fos-deployment && kubectl rollout status ds/fos-deployment  
podname=$(kubectl get pod -l app=fos  | grep Running | grep fos | cut -d " " -f 1) 
echo   'check cfos iptables for snat entry' && kubectl exec -it po/ -- iptables -L -t nat --verbose | grep MASQ 
echo "check whether application pod can reach "
echo "check deployment multi"
echo sleep 30
sleep 30
kubectl get pod | grep multi | grep -v termin  | awk '{print }'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
echo 'done'
```
- check the result

- check deployment status of cFOS

`
kubectl rollout status ds/fos-deployment
`
```
daemon set "fos-deployment" successfully rolled out
```
check cfos iptables entry

check routing table and ip address

`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; echo $podName
;  kubectl exec -it po/$podName -- iptables -L -t nat --verbose | grep MASQ ; done
`
```
fos-deployment-mrh6nn
   29  2416 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
fos-deployment-gjf2bn
   29  2416 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
```
check ping result

`
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
`
```
pod multitool01-deployment-7f5bf4b7cd-65svd
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.79 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.786/4.786/4.786/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-d9ft9
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.61 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.608/4.608/4.608/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-h4mnw
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.39 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.385/4.385/4.385/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-l8cdc
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=5.95 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.953/5.953/5.953/0.000 ms
```
end of ./../11_cfos_ds_restart.sh.shell.sh.gen.sh.md


cat ./../12_ipstest.sh.shell.sh.gen.sh.md


- do a ips test on a target website

it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the IPS signature. if match the signature. cFOS can either block it or pass it with alert depends on the policy configured.

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it. 
you will exepct to see ips traffic log with matched firewall policy id to indicate which policy is in action.

- paste below command to send malicous traffic from application pod
 
```
echo -e 'generate traffic to www.hackthebox.eu' 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- dig www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- ping -c 2  www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://www.hackthebox.eu ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 300 ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 300  ; done
`
```
date=2023-08-01 time=11:22:17 eventtime=1690888937 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=7 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=39966 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274689 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:22:35 eventtime=1690888955 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=41388 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274690 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:22:24 eventtime=1690888944 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=35864 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609665 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:22:29 eventtime=1690888949 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=55610 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609666 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
end of ./../12_ipstest.sh.shell.sh.gen.sh.md


cat ./../13_webftest.sh.shell.sh.gen.sh.md


- do a web filter  test on a target website 

it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will expect to see web filter log with matched policy id to indicate which firewall policy is in action
- paste below command initial access to the target website 

```
echo -e 'generate traffic to https://www.casino.org' 

kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.casino.org  ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=300 ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 300 ; done
`
```
date=2023-08-01 time=11:22:50 eventtime=1690888970 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.21 srcport=47956 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:22:54 eventtime=1690888974 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=9 srcip=10.1.200.20 srcport=44864 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:22:51 eventtime=1690888971 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=8 srcip=10.1.200.20 srcport=39532 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:22:53 eventtime=1690888973 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=8 srcip=10.1.200.21 srcport=46806 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
```
end of ./../13_webftest.sh.shell.sh.gen.sh.md


cat ./../17_delete_policy_300.sh.shell.sh.gen.sh.md


- use cfos restful API to delete firewall policy 

we can use cFOS shell to change firewall policy, we can also use cFOS restAPI to do the same. 
after delete firewall policy, ping to 1.1.1.1 from application pod will no longer reachable
- paste below command delete firewall policy 

```
nodeList=$(kubectl get pod -l app=fos -o jsonpath='{.items[*].status.podIP}')
kubectl delete cm foscfgfirewallpolicy
echo $nodeList
apppodname=$(kubectl get pod | grep multi | grep -v termin  | awk '{print $1}' | head -1)
for i in $nodeList; do {
kubectl exec -it po/$apppodname -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/300"
}
done
```
- check the result

`
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do echo -e pod $line; kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
`
```
pod multitool01-deployment-7f5bf4b7cd-65svd
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

pod multitool01-deployment-7f5bf4b7cd-d9ft9
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

pod multitool01-deployment-7f5bf4b7cd-h4mnw
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

pod multitool01-deployment-7f5bf4b7cd-l8cdc
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

```
end of ./../17_delete_policy_300.sh.shell.sh.gen.sh.md


cat ./../18_create_policy_manager.sh.md


- create an POD to update POD source IP to cFOS
 
POD IPs are keep changing due to scale in/out or reborn , deleting etc for various reason, we need to keep update the POD ip address to cFOS address group. 
we create a POD dedicated for this. this POD keep running a background proces which update the application POD's IP  that has annoation to net-attach-def *"* to cFOS via cFOS restful API. 
the API call to cFOS can use either cFOS dns name or cFOS node IPs. if cFOS use shared storage for configuration, then use dns name is proper way, otherwise, we will need to update each cFOS POD directly via CFOS POD ip address. the policy_manager by default using cFOS POD ip address. 
the policy_manager also create  firewallpolicy for target application unless the policy has already createdby gatekeeper. this is only for demo purpose.  the firewall policy created on cFOS has fixed policyID=200
the policy_manager pod use image from *interbeing/kubectl-cfos:gke_demo_v1*
the source code of this image is under policymanager/
build.sh  Dockerfile  script.sh
you can build by yourself. 
- paste below command to create policy_manager 

```
#!/bin/bash

filename="18_cfospolicymanager.yml"
[[ -z $policymanagerimage ]] && policymanagerimage="interbeing/kubectl-cfos:gke_demo_v2"
[[ -z $app_nad_annotation ]] && app_nad_annotation="cfosapp"
[[ -z $cfos_label ]] && cfos_label="fos"
function wait_for_pod_ready {
pod_name=$(kubectl get pods -l app=policy_manager -o jsonpath='{.items[0].metadata.name}')

while true; do
    pod_status=$(kubectl get pods $pod_name -o jsonpath='{.status.phase}')
    if [[ $pod_status == "Running" ]]; then
	kubectl get pod -l app=policy_manager
        break
    else
        echo "Waiting for pod to be in Running state..."
        sleep 5
    fi
done

}

cat << EOF > $filename
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "get", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["list","get","watch","create"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list", "get", "watch"]
- apiGroups: ["apps"]
  resources: ["daemonsets"]
  verbs: ["get", "list", "watch", "patch", "update"]
- apiGroups: ["constraints.gatekeeper.sh"]
  resources: ["k8segressnetworkpolicytocfosutmpolicy"]
  verbs: ["list","get","watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: pod-reader
  namespace: default

---
apiVersion: v1
kind: Pod
metadata:
  name: policymanager
  labels: 
    app: policy_manager
spec:
  serviceAccountName: pod-reader
  containers:
  - name: kubectl-container
    image: $policymanagerimage
    env:
      - name: app_label
        value: $app_nad_annotation

EOF

kubectl apply -f $filename  && wait_for_pod_ready && kubectl exec -it po/policymanager -- curl -X GET "http://$cfos_label-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy" && kubectl exec -it po/policymanager -- curl -X GET "http://$cfos_label-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp" 
```
- check the result

`
kubectl get pod policymanager && kubectl exec -it po/policymanager -- curl -X GET "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp"
`
```
NAME            READY   STATUS    RESTARTS   AGE
policymanager   1/1     Running   0          16s
{
  "status": "success",
  "http_status": 200,
  "path": "firewall",
  "name": "addrgrp",
  "http_method": "GET",
  "results": [
    {
      "name": "defaultappmultitool",
      "type": "default",
      "category": "default",
      "member": [
        {
          "name": "10.1.200.21"
        },
        {
          "name": "10.1.200.20"
        },
        {
          "name": "10.1.200.21"
        },
        {
          "name": "10.1.200.20"
        }
      ],
      "comment": "",
      "exclude": "disable",
      "exclude-member": [
        {
          "name": "none"
        }
      ]
    }
  ],
  "serial": "FGVMULTM23000044",
  "version": "v7.2.0",
  "build": "231"
}

```
end of ./../18_create_policy_manager.sh.md


cat ./../22_ipstest.sh.shell.sh.gen.sh.md


- do a ips test on a target website

we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is 101
- paste below command to send malicous traffic from application pod
 
```
echo -e "generate traffic to www.hackthebox.eu"
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- dig www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- ping -c 2  www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://www.hackthebox.eu ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=101 ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=101 ; done
`
```
date=2023-08-01 time=11:58:41 eventtime=1690891121 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=33502 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274691 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:59:00 eventtime=1690891140 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=41214 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274692 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:58:48 eventtime=1690891128 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=54780 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609667 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=11:58:54 eventtime=1690891134 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=54444 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609668 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
end of ./../22_ipstest.sh.shell.sh.gen.sh.md


cat ./../23_webftest.sh.shell.sh.gen.sh.md


- do a web filter  test on a target website

same to web fitler traffic
- paste below command initial access to the target website
 
```
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.casino.org  ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=101  ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=101  ; done
`
```
date=2023-08-01 time=11:59:14 eventtime=1690891154 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.21 srcport=34680 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:18 eventtime=1690891158 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=7 srcip=10.1.200.20 srcport=37342 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:16 eventtime=1690891156 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.20 srcport=41710 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:17 eventtime=1690891157 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=7 srcip=10.1.200.21 srcport=40722 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
```
end of ./../23_webftest.sh.shell.sh.gen.sh.md


cat ./../24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh.shell.sh.gen.sh.md


- modify worker node default CNI config


in previous section, we did not touch application POD's default route, only we interested destination like 1.1.1.1 is send to cFOS, the rest of traffic will contine go to internet via default route, what about if want send all traffic from application POD to cFOS ,to doing this,
we will need then insert a default route into application pod, for this purpose, we will need use add annotation with keyword default-route to the POD definition. but this is not enough. as you still want some other traffic continue to go to default interface instead goes to cFOS, for example, the traffic goes to gke cluster IP and cross POD to POD traffic. the GKE default cni come with host-local ipam, inside host-local ipam , we can insert custom route, we added clusterIP CIDR range and POD IP CIDR range, after that, restart multus DaemonSet to update Multus default config .

- paste below command to modify default GKE cni config to insert route 

```

clustersearchstring=my-first-cluster-1 
namelist=$(gcloud compute instances list --filter="name~''"  --format="value(name)" ) 
for name in $namelist ; do {

route_exists=$(gcloud compute ssh $name --command="sudo grep -E '\"dst\": \"10.144.0.0\/20\"|\"dst\": \"10.140.0.0\/14\"' /etc/cni/net.d/10-containerd-net.conflist")

if [ -z "$route_exists" ]; then
  gcloud compute ssh $name --command="sudo sed -i '/\"dst\": \"0.0.0.0\/0\"/!b;n;N;s/        \]$/,\n          {\"dst\": \"10.144.0.0\/20\"},\n          {\"dst\": \"10.140.0.0\/14\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"
kubectl rollout restart ds/kube-multus-ds -n kube-system && 
kubectl rollout status ds/kube-multus-ds -n kube-system 
kubectl logs  ds/kube-multus-ds -n kube-system
fi


kubectl logs  ds/kube-multus-ds -n kube-system
}
done
```
- check the result

`
kubectl logs ds/kube-multus-ds -n kube-system
`
```
2023-08-01T12:00:30+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-08-01T12:00:30+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-08-01T12:00:31+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-08-01T12:00:31+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
2023-08-01T12:00:32+00:00 Config file created @ /host/etc/cni/net.d/00-multus.conf
{ "cniVersion": "0.3.1", "name": "multus-cni-network", "type": "multus", "capabilities": {"portMappings": true}, "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig", "delegates": [ { "name": "k8s-pod-network", "cniVersion": "0.3.1", "plugins": [ { "type": "ptp", "mtu": 1460, "ipam": { "type": "host-local", "subnet": "10.140.1.0/24", "routes": [ { "dst": "0.0.0.0/0" } , {"dst": "10.144.0.0/20"}, {"dst": "10.140.0.0/14"} ] } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] } ] }
2023-08-01T12:00:32+00:00 Entering sleep (success)...
```
end of ./../24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh.shell.sh.gen.sh.md


cat ./../25_delete_app.sh.md


- delete current appliation deployment
 

- paste below command to delete
 
```
kubectl get deployment multitool01-deployment && kubectl delete deployment multitool01-deployment
```
end of ./../25_delete_app.sh.md


cat ./../26_create_app_deployment_multtool_with_defaultroute.sh.shell.sh.yml.sh.md


- create application deployment 


create deployment with annotation to use net-attach-def and also config default route point to net-attach-def attached interface. which is cFOS interface. 
the annotation field has context 
*k8s.v1.cni.cncf.io/networks: '[ { "name": "",  "default-route": ["10.1.200.252"]  } ]'* , which config an default route with nexthop to 10.1.200.252.
check ip route table on application shall see the default route point to cFOS interface. 
- paste below command to create deployment 

```
cat << EOF | kubectl create -f - 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 4
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp", "default-route": ["10.1.200.252"] } ]'
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
          #image: praqma/network-multitool
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF

kubectl rollout status deployment multitool01-deployment
echo "sleep 30 seconds for it will take some time to trigger policymanager to update cfos addressgrp"
sleep 30
```
- check the result

`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.1.200.252 dev net1 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.23 
10.140.0.0/14 via 10.140.1.1 dev eth0 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.11 
10.140.1.1 dev eth0 scope link src 10.140.1.11 
10.144.0.0/20 via 10.140.1.1 dev eth0 
89.238.73.97 via 10.1.200.252 dev net1 
104.17.0.0/16 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
104.21.42.126 via 10.1.200.252 dev net1 
172.67.162.8 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 56:de:53:66:8c:71 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.11/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ca:36:94:00:72:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.23/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.1.200.252 dev net1 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.23 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.14 
10.140.0.0/14 via 10.140.0.1 dev eth0 
10.140.0.1 dev eth0 scope link src 10.140.0.14 
10.144.0.0/20 via 10.140.0.1 dev eth0 
89.238.73.97 via 10.1.200.252 dev net1 
104.17.0.0/16 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
104.21.42.126 via 10.1.200.252 dev net1 
172.67.162.8 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 02:f0:b3:58:fa:6a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.14/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether da:3a:e3:fd:d9:0c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.23/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
end of ./../26_create_app_deployment_multtool_with_defaultroute.sh.shell.sh.yml.sh.md


cat ./../27_webftest.sh.shell.sh.gen.sh.md


- do a web filter  test on a target website

this time we ,use destination that not on match default route, for example https://xoso.com.vn  this website will be classified by cFOS as Gambling that shall be blocked by default profile.

- paste below command initial access to the target website 
```
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://xoso.com.vn  ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=101  ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=101  ; done
`
```
date=2023-08-01 time=11:59:14 eventtime=1690891154 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.21 srcport=34680 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:18 eventtime=1690891158 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=7 srcip=10.1.200.20 srcport=37342 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:01:36 eventtime=1690891296 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.23 srcport=34328 srcintf="net1" dstip=104.18.25.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:01:38 eventtime=1690891298 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=7 srcip=10.1.200.22 srcport=44486 srcintf="net1" dstip=104.18.24.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:16 eventtime=1690891156 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.20 srcport=41710 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=11:59:17 eventtime=1690891157 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=7 srcip=10.1.200.21 srcport=40722 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:01:34 eventtime=1690891294 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=5 srcip=10.1.200.23 srcport=35474 srcintf="net1" dstip=104.18.25.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=115 rcvdbyte=40 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:01:37 eventtime=1690891297 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=9 srcip=10.1.200.22 srcport=39862 srcintf="net1" dstip=104.18.25.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
```
end of ./../27_webftest.sh.shell.sh.gen.sh.md


cat ./../38_delete_policy_101.sh.shell.sh.gen.sh.md


- use cfos restful API to delete firewall policy
 
the policy created by policy_manager pod has policy id 101, let us delete this firewall policy use cfosrestapi. 
after delete firewall policy, we use crl to check whether any firewall policy left on cFOS POD
- paste below command delete firewall policy
 
```
nodeList=$(kubectl get pod -l app=fos -o jsonpath='{.items[*].status.podIP}')
for i in $nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/101"
}
done
```
- check the result

`
kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy/101
`
```
{
  "status": "error",
  "http_status": 404,
  "http_method": "GET",
  "path": "firewall",
  "name": "policy",
  "error": "failed to load config",
  "serial": "FGVMULTM23000044",
  "version": "v7.2.0",
  "build": "231"
}

```
end of ./../38_delete_policy_101.sh.shell.sh.gen.sh.md


cat ./../46_install_gatekeeperv3.sh.md


- install gatekeeperv3 

We will use standard k8s networkpolicy to create firewallpolicy for cFOS, the networkpolicy submitted by kubectl will first be send to gatekeeper admission controller. where there is a constraint delpoyed to inspect the policy constraint via constraint template. if the networkpolicy pass the constrait check. the constraint template will use cFOS Restapi to create firewall policy. and then the constraint template will give output telling the networkpolicy creation is forbiden instead it created on CFOS. 

- paste below command to install gatekeeper 

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml && \
kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system &&  \
kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system  && kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system



```
- check the result

check gatekeeper installation status
`
kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system &&  kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system  && kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system
`
```
deployment "gatekeeper-audit" successfully rolled out
deployment "gatekeeper-controller-manager" successfully rolled out
deployment "gatekeeper-audit" successfully rolled out
```
end of ./../46_install_gatekeeperv3.sh.md


cat ./../47_create_gatekeeper_constraint_template.sh.md


- install gatekeeperv3 constraint template 
 

in this template, include a session call targets. in the targets it use rego as policy engine language to parse the policy . 
we use repo function *http.send* to send API to cFOS. you only need deploy template once.  
- paste below command to install gatekeeper constraint template
 
```
filename="47_constraint_template.yml"

cat << EOF > $filename
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8segressnetworkpolicytocfosutmpolicy
spec:
  crd:
    spec:
      names:
        kind: K8sEgressNetworkPolicyToCfosUtmPolicy
      validation:
        openAPIV3Schema:
          properties:
            message:
              type: string
            podcidr:
              type: string
            cfosegressfirewallpolicy:
              type: string 
            outgoingport:
              type: string
            utmstatus:
              type: string
            ipsprofile:
              type: string
            avprofile:
              type: string
            sslsshprofile:
              type: string 
            action:
              type: string
            srcintf:
              type: string
            firewalladdressapiurl:
              type: string
            firewallpolicyapiurl:
              type: string
            policyid :
              type: string 
            extraservice:
              type: string 

  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8segressnetworkpolicytocfosutmpolicy
        import future.keywords.if
        import future.keywords.in
        import future.keywords.contains
        
        
        services := {
        "HTTP": ["TCP:80"],
        "HTTPS": ["TCP:443"],
        "DNS": ["UDP:53"]
        }

        get_service(cfosservice) := msg1 {
          protocol := input.review.object.spec.egress[_].ports[_].protocol 
          port := sprintf("%v",[input.review.object.spec.egress[_].ports[_].port])
          key := concat(":", [ protocol, port ])
          some service; services[service][_] == key
          test := { service }
          cfosservice in test
          msg1 := cfosservice
         }

        myservice[{
           "name" : get_service("HTTPS")
          }] {
               1==1
         }
        myservice[{
           "name" : get_service("HTTP")
          }] {
               1==1
         }
        myservice[{
           "name" : get_service("DNS")
          }] {
               1==1
         }

         myservice[{"name":msg1}] {
         input.parameters.extraservice=="PING"
         msg1:="PING"
         }



          violation[{
            "msg" : msg 
          }] {
                          

                          
                          #the NetworkPolicy must has label under metadata which match the constraint
                          input.review.object.metadata.labels.app==input.parameters.label
                          
                          
                          #GET INPUT from reguar NetworkPolicy for cfos firewall policy
                          namespace := input.review.object.metadata.namespace
                          label := input.review.object.spec.podSelector.matchLabels.app
                             t := concat("",[namespace,"app"])
                          src_addr_group := concat("",[t,label])
                          dstipblock :=  input.review.object.spec.egress[_].to[_].ipBlock.cidr
                          policyname := input.review.object.metadata.name
                          
                          #GET INPUT from constraint template
                          policyid := input.parameters.policyid 
                          ipsprofile := input.parameters.ipsprofile
                          avprofile := input.parameters.avprofile
                          sslsshprofile := input.parameters.sslsshprofile
                          action  := input.parameters.action
                          srcintf := input.parameters.srcintf   
                          utmstatus := input.parameters.utmstatus
                          outgoingport := input.parameters.outgoingport
                          
                          
                          #firewalladdressapiurl := input.parameters.firewalladdressapiurl
                          firewallpolicyapiurl := input.parameters.firewallpolicyapiurl
                          firewalladdrgrpapiurl := input.parameters.firewalladdressgrpapiurl
        
                            #Begin Update cfos AddrGrp
                            #AddrGrp has an member with name "none"
                                      
                                      headers := {
                                      "Content-Type": "application/json",
                                      }
                            
                                      addrgrpbody := {
                                        "data":  {"name": src_addr_group, "member": [{"name": "none"}]}
                                      }
                            
                            
                                      addrGroupResp := http.send({
                                        "method": "POST",
                                        "url":  firewalladdrgrpapiurl,
                                        "headers": headers,
                                        "body": addrgrpbody
                                      })
                                      
                            #End Update cfos AddrGrp

                                      
                            #Begin of Firewall Policy update
                                      
                                      firewallPolicybody := {
                                        "data": 
                                          {"policyid":policyid, 
                                                  "name": policyname, 
                                                  "srcintf": [{"name": srcintf}], 
                                                  "dstintf": [{"name": outgoingport}], 
                                                  "srcaddr": [{"name": src_addr_group}],
                                                    #"service": [{"name":"ALL"}],
                                                  "service": myservice,
                                                  "nat":"enable",
                                                  "utm-status":utmstatus,
                                                  "action": "accept",
                                                  "logtraffic": "all",
                                                  "ssl-ssh-profile": sslsshprofile,
                                                  "ips-sensor": ipsprofile,
                                                  "webfilter-profile": "default",
                                                  "av-profile": avprofile,
                                                  "dstaddr": [{"name": "all"}]
                                          }
                                      }
                                      
                                      firewallPolicyResp := http.send({
                                        "method": "POST",
                                         "url":firewallpolicyapiurl, 
                                       "headers": headers,
                                         "body": firewallPolicybody
                                       })
                                      
                            #End of Firewall Policy Update       
 
                      msg :=sprintf(  "\n{%v %v  %v} ", [
                                                            addrGroupResp.status_code,
                                                            firewallPolicyResp.status_code,
                                                            myservice
                                                    ]
                                   )
              } 

EOF
kubectl create -f $filename 
kubectl get constrainttemplates -o yaml

```
- check the result

check constraint template

`
kubectl get constrainttemplates -o yaml
`
```
apiVersion: v1
items:
- apiVersion: templates.gatekeeper.sh/v1
  kind: ConstraintTemplate
  metadata:
    creationTimestamp: "2023-08-01T12:02:24Z"
    generation: 1
    name: k8segressnetworkpolicytocfosutmpolicy
    resourceVersion: "22871"
    uid: 7a588fa0-2a6f-4abd-851a-63e9605b4f20
  spec:
    crd:
      spec:
        names:
          kind: K8sEgressNetworkPolicyToCfosUtmPolicy
        validation:
          legacySchema: true
          openAPIV3Schema:
            properties:
              action:
                type: string
              avprofile:
                type: string
              cfosegressfirewallpolicy:
                type: string
              extraservice:
                type: string
              firewalladdressapiurl:
                type: string
              firewallpolicyapiurl:
                type: string
              ipsprofile:
                type: string
              message:
                type: string
              outgoingport:
                type: string
              podcidr:
                type: string
              policyid:
                type: string
              srcintf:
                type: string
              sslsshprofile:
                type: string
              utmstatus:
                type: string
    targets:
    - rego: "package k8segressnetworkpolicytocfosutmpolicy\nimport future.keywords.if\nimport
        future.keywords.in\nimport future.keywords.contains\n\n\nservices := {\n\"HTTP\":
        [\"TCP:80\"],\n\"HTTPS\": [\"TCP:443\"],\n\"DNS\": [\"UDP:53\"]\n}\n\nget_service(cfosservice)
        := msg1 {\n  protocol := input.review.object.spec.egress[_].ports[_].protocol
        \n  port := sprintf(\"%v\",[input.review.object.spec.egress[_].ports[_].port])\n
        \ key := concat(\":\", [ protocol, port ])\n  some service; services[service][_]
        == key\n  test := { service }\n  cfosservice in test\n  msg1 := cfosservice\n
        }\n\nmyservice[{\n   \"name\" : get_service(\"HTTPS\")\n  }] {\n       1==1\n
        }\nmyservice[{\n   \"name\" : get_service(\"HTTP\")\n  }] {\n       1==1\n
        }\nmyservice[{\n   \"name\" : get_service(\"DNS\")\n  }] {\n       1==1\n
        }\n\n myservice[{\"name\":msg1}] {\n input.parameters.extraservice==\"PING\"\n
        msg1:=\"PING\"\n }\n\n\n\n  violation[{\n    \"msg\" : msg \n  }] {\n                  \n\n
        \                 \n                  #the NetworkPolicy must has label under
        metadata which match the constraint\n                  input.review.object.metadata.labels.app==input.parameters.label\n
        \                 \n                  \n                  #GET INPUT from
        reguar NetworkPolicy for cfos firewall policy\n                  namespace
        := input.review.object.metadata.namespace\n                  label := input.review.object.spec.podSelector.matchLabels.app\n
        \                    t := concat(\"\",[namespace,\"app\"])\n                  src_addr_group
        := concat(\"\",[t,label])\n                  dstipblock :=  input.review.object.spec.egress[_].to[_].ipBlock.cidr\n
        \                 policyname := input.review.object.metadata.name\n                  \n
        \                 #GET INPUT from constraint template\n                  policyid
        := input.parameters.policyid \n                  ipsprofile := input.parameters.ipsprofile\n
        \                 avprofile := input.parameters.avprofile\n                  sslsshprofile
        := input.parameters.sslsshprofile\n                  action  := input.parameters.action\n
        \                 srcintf := input.parameters.srcintf   \n                  utmstatus
        := input.parameters.utmstatus\n                  outgoingport := input.parameters.outgoingport\n
        \                 \n                  \n                  #firewalladdressapiurl
        := input.parameters.firewalladdressapiurl\n                  firewallpolicyapiurl
        := input.parameters.firewallpolicyapiurl\n                  firewalladdrgrpapiurl
        := input.parameters.firewalladdressgrpapiurl\n\n                    #Begin
        Update cfos AddrGrp\n                    #AddrGrp has an member with name
        \"none\"\n                              \n                              headers
        := {\n                              \"Content-Type\": \"application/json\",\n
        \                             }\n                    \n                              addrgrpbody
        := {\n                                \"data\":  {\"name\": src_addr_group,
        \"member\": [{\"name\": \"none\"}]}\n                              }\n                    \n
        \                   \n                              addrGroupResp := http.send({\n
        \                               \"method\": \"POST\",\n                                \"url\":
        \ firewalladdrgrpapiurl,\n                                \"headers\": headers,\n
        \                               \"body\": addrgrpbody\n                              })\n
        \                             \n                    #End Update cfos AddrGrp\n\n
        \                             \n                    #Begin of Firewall Policy
        update\n                              \n                              firewallPolicybody
        := {\n                                \"data\": \n                                  {\"policyid\":policyid,
        \n                                          \"name\": policyname, \n                                          \"srcintf\":
        [{\"name\": srcintf}], \n                                          \"dstintf\":
        [{\"name\": outgoingport}], \n                                          \"srcaddr\":
        [{\"name\": src_addr_group}],\n                                            #\"service\":
        [{\"name\":\"ALL\"}],\n                                          \"service\":
        myservice,\n                                          \"nat\":\"enable\",\n
        \                                         \"utm-status\":utmstatus,\n                                          \"action\":
        \"accept\",\n                                          \"logtraffic\": \"all\",\n
        \                                         \"ssl-ssh-profile\": sslsshprofile,\n
        \                                         \"ips-sensor\": ipsprofile,\n                                          \"webfilter-profile\":
        \"default\",\n                                          \"av-profile\": avprofile,\n
        \                                         \"dstaddr\": [{\"name\": \"all\"}]\n
        \                                 }\n                              }\n                              \n
        \                             firewallPolicyResp := http.send({\n                                \"method\":
        \"POST\",\n                                 \"url\":firewallpolicyapiurl,
        \n                               \"headers\": headers,\n                                 \"body\":
        firewallPolicybody\n                               })\n                              \n
        \                   #End of Firewall Policy Update       \n\n              msg
        :=sprintf(  \"\\n{%v %v  %v} \", [\n                                                    addrGroupResp.status_code,\n
        \                                                   firewallPolicyResp.status_code,\n
        \                                                   myservice\n                                            ]\n
        \                          )\n      } \n"
      target: admission.k8s.gatekeeper.sh
  status:
    byPod:
    - errors:
      - code: create_error
        message: 'Could not create CRD: customresourcedefinitions.apiextensions.k8s.io
          "k8segressnetworkpolicytocfosutmpolicy.constraints.gatekeeper.sh" already
          exists'
      id: gatekeeper-audit-7fb8f4c95c-gx4g4
      observedGeneration: 1
      operations:
      - audit
      - mutation-status
      - status
      templateUID: 7a588fa0-2a6f-4abd-851a-63e9605b4f20
    created: false
kind: List
metadata:
  resourceVersion: ""
```
end of ./../47_create_gatekeeper_constraint_template.sh.md


cat ./../48_deploy_constraint_fos_cfos.sh.shell.sh.yml.sh.md


- install policy constraint
   

the policy constraint define what API to watch, for example, here we wathc NetworkPolicy API, also it  function as parameter input to constraint template. here for example, user pass in policy id=200 for constraint template. we also pass in cFOS restAPI URL etc., 
beaware that here we are using dns name of clusterIP for cFOS API, if we are not using shared  storage for cFOS /data folder, we need run API call multiple times to make sure it config each of cFOS POD. 

- paste below command to install policy constraint template 

```
cat << EOF | kubectl create -f - 
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sEgressNetworkPolicyToCfosUtmPolicy
metadata:
  name: cfosnetworkpolicy
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: ["networking.k8s.io"]
        kinds: ["NetworkPolicy"]
  parameters:
    firewalladdressapiurl : "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address"
    firewallpolicyapiurl : "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy"
    firewalladdressgrpapiurl: "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp"
    policyid : "200"
    label: "cfosegressfirewallpolicy"
    outgoingport: "eth0"
    utmstatus: "enable"
    ipsprofile: "default"
    avprofile: "default"
    sslsshprofile: "deep-inspection"
    action: "permit"
    srcintf: "any"
    extraservice: "PING"
EOF
kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml
```
- check the result

check constraint
 
`
kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml
`
```
apiVersion: v1
items:
- apiVersion: constraints.gatekeeper.sh/v1beta1
  kind: K8sEgressNetworkPolicyToCfosUtmPolicy
  metadata:
    creationTimestamp: "2023-08-01T12:02:27Z"
    generation: 1
    name: cfosnetworkpolicy
    resourceVersion: "22921"
    uid: 4a8f2414-f1e7-4545-ac89-99211da466d8
  spec:
    enforcementAction: deny
    match:
      kinds:
      - apiGroups:
        - networking.k8s.io
        kinds:
        - NetworkPolicy
    parameters:
      action: permit
      avprofile: default
      extraservice: PING
      firewalladdressapiurl: http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address
      firewalladdressgrpapiurl: http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp
      firewallpolicyapiurl: http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy
      ipsprofile: default
      label: cfosegressfirewallpolicy
      outgoingport: eth0
      policyid: "200"
      srcintf: any
      sslsshprofile: deep-inspection
      utmstatus: enable
  status:
    byPod:
    - constraintUID: 4a8f2414-f1e7-4545-ac89-99211da466d8
      enforced: true
      id: gatekeeper-audit-7fb8f4c95c-gx4g4
      observedGeneration: 1
      operations:
      - audit
      - mutation-status
      - status
    - constraintUID: 4a8f2414-f1e7-4545-ac89-99211da466d8
      enforced: true
      id: gatekeeper-controller-manager-7db564f9f4-4pfmh
      observedGeneration: 1
      operations:
      - mutation-webhook
      - webhook
    - constraintUID: 4a8f2414-f1e7-4545-ac89-99211da466d8
      enforced: true
      id: gatekeeper-controller-manager-7db564f9f4-gtjkx
      observedGeneration: 1
      operations:
      - mutation-webhook
      - webhook
    - constraintUID: 4a8f2414-f1e7-4545-ac89-99211da466d8
      enforced: true
      id: gatekeeper-controller-manager-7db564f9f4-mkv76
      observedGeneration: 1
      operations:
      - mutation-webhook
      - webhook
kind: List
metadata:
  resourceVersion: ""
```
end of ./../48_deploy_constraint_fos_cfos.sh.shell.sh.yml.sh.md


cat ./../49_deploy_network_firewall_policy_egress.sh.md


- create standard networkpolicy
   
here we create standard  k8s egress networkpolicy, this policy will be created on cFOS with gatekeeper help. 
after creating. use "kubectl get networkpolicy will not show you the policy" as it actually created on cFOS. 
instead , you can get policy by use cFOS API with command *kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy*
- paste below command to deploy networkpolicy
 
```
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"
filename="49_network_firewallpolicy_egress.yml"
cat << EOF >$filename
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: createdbygatekeeper
  labels:
    app: cfosegressfirewallpolicy
spec:
  podSelector:
    matchLabels:
      app: multitool
      namespace: default
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
EOF

#node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
node_list=$(kubectl get pod -l app=$cfos_label -o jsonpath='{.items[*].status.podIP}')

for node in $node_list;  do  {

while true ; do 
	kubectl apply -f $filename
	sleep 5
	number_of_cfos_pod_applied=$(kubectl exec -it po/policymanager -- curl -X GET "$node/api/v2/cmdb/firewall/policy/$gatekeeper_policy_id" | grep policyid | wc -l)
	echo number_of_cfos_pod_applied is $number_of_cfos_pod_applied
	if [ $number_of_cfos_pod_applied -eq 1 ]; then
          break
        fi
done
}

done

```
- check the result

`
kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy && kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy
`
```
{
  "status": "success",
  "http_status": 200,
  "path": "firewall",
  "name": "policy",
  "http_method": "GET",
  "results": [
    {
      "policyid": "200",
      "status": "enable",
      "utm-status": "enable",
      "name": "createdbygatekeeper",
      "comments": "",
      "srcintf": [
        {
          "name": "any"
        }
      ],
      "dstintf": [
        {
          "name": "eth0"
        }
      ],
      "srcaddr": [
        {
          "name": "defaultappmultitool"
        }
      ],
      "dstaddr": [
        {
          "name": "all"
        }
      ],
      "srcaddr6": [],
      "dstaddr6": [],
      "service": [
        {
          "name": "HTTP"
        },
        {
          "name": "HTTPS"
        },
        {
          "name": "PING"
        }
      ],
      "ssl-ssh-profile": "deep-inspection",
      "profile-type": "single",
      "profile-group": "",
      "profile-protocol-options": "default",
      "av-profile": "default",
      "webfilter-profile": "default",
      "dnsfilter-profile": "",
      "emailfilter-profile": "",
      "dlp-sensor": "",
      "file-filter-profile": "",
      "ips-sensor": "default",
      "application-list": "",
      "action": "accept",
      "nat": "enable",
      "custom-log-fields": [],
      "logtraffic": "all"
    }
  ],
  "serial": "FGVMULTM23000044",
  "version": "v7.2.0",
  "build": "231"
}{
  "status": "success",
  "http_status": 200,
  "path": "firewall",
  "name": "policy",
  "http_method": "GET",
  "results": [
    {
      "policyid": "200",
      "status": "enable",
      "utm-status": "enable",
      "name": "createdbygatekeeper",
      "comments": "",
      "srcintf": [
        {
          "name": "any"
        }
      ],
      "dstintf": [
        {
          "name": "eth0"
        }
      ],
      "srcaddr": [
        {
          "name": "defaultappmultitool"
        }
      ],
      "dstaddr": [
        {
          "name": "all"
        }
      ],
      "srcaddr6": [],
      "dstaddr6": [],
      "service": [
        {
          "name": "HTTP"
        },
        {
          "name": "HTTPS"
        },
        {
          "name": "PING"
        }
      ],
      "ssl-ssh-profile": "deep-inspection",
      "profile-type": "single",
      "profile-group": "",
      "profile-protocol-options": "default",
      "av-profile": "default",
      "webfilter-profile": "default",
      "dnsfilter-profile": "",
      "emailfilter-profile": "",
      "dlp-sensor": "",
      "file-filter-profile": "",
      "ips-sensor": "default",
      "application-list": "",
      "action": "accept",
      "nat": "enable",
      "custom-log-fields": [],
      "logtraffic": "all"
    }
  ],
  "serial": "FGVMULTM23000044",
  "version": "v7.2.0",
  "build": "231"
}

```
end of ./../49_deploy_network_firewall_policy_egress.sh.md


cat ./../50_restart_app.sh.md


- restart application deployment to trigger policymanager update addressgrp in cFOS 
due to limitation of policymanager, it require pod ip change to trigger update addressgrp in cFOS, we can restar application pod, scale in, scale out etc to force pod IP change. 
you can use "kubectl logs -f po/policymanager" to check the log of policymanager 

- paste below command to restart appliation DaemonSet 

```
kubectl rollout restart deployment multitool01-deployment && kubectl rollout status deployment multitool01-deployment
echo "sleep 30 seconds for it will take some time to trigger policymanager to update cfos addressgrp"
sleep 30
```
- check the result

`
kubectl rollout status deployment multitool01-deployment
`
```
deployment "multitool01-deployment" successfully rolled out
```
end of ./../50_restart_app.sh.md


cat ./../52_ipstest.sh.shell.sh.gen.sh.md


- do a ips test on a target website

we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is 200
- paste below command to send malicous traffic from application pod
 
```
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- dig www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line -- ping -c 2  www.hackthebox.eu ; done 
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://www.hackthebox.eu ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=200 ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=200 ; done
`
```
date=2023-08-01 time=12:04:40 eventtime=1690891480 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.24 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=47570 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274693 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=12:04:46 eventtime=1690891486 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.25 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=56604 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=92274694 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=12:04:27 eventtime=1690891467 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.24 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=55724 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609669 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-08-01 time=12:04:34 eventtime=1690891474 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.25 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=41132 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=250609670 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
end of ./../52_ipstest.sh.shell.sh.gen.sh.md


cat ./../53_webftest.sh.shell.sh.gen.sh.md


- do a web filter  test on a target website


- paste below command initial access to the target website
 
```
kubectl get pod | grep multi | grep -v termin | awk '{print }'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.casino.org  ; done
kubectl get pod | grep fos | awk '{print }'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=200  ; done
```
- check the result

`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=200  ; done
`
```
date=2023-08-01 time=12:05:03 eventtime=1690891503 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=7 srcip=10.1.200.24 srcport=58370 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:05:04 eventtime=1690891504 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=3 srcip=10.1.200.25 srcport=45184 srcintf="net1" dstip=104.17.142.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:05:00 eventtime=1690891500 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=3 srcip=10.1.200.24 srcport=32882 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-08-01 time=12:05:02 eventtime=1690891502 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=7 srcip=10.1.200.25 srcport=48958 srcintf="net1" dstip=104.17.143.29 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.casino.org" profile="default" action="blocked" reqtype="direct" url="https://www.casino.org/" sentbyte=109 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
```
end of ./../53_webftest.sh.shell.sh.gen.sh.md


