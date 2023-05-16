- create network for gke cluster 

create network for GKE VM instances.
the *ipcidrRange* is the ip range for VM node. 
the *firewallallowProtocol=all* allow ssh into worker node from anywhere  to all protocols
- paste below command to create network, subnets and firewall-rules  
```
#!/bin/bash -xe
echo $networkName

[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"
[[ $ipcidrRange == "" ]] && ipcidrRange="10.0.0.0/24"
[[ $firewallruleName == "" ]] && firewallruleName="$networkName-allow-custom"
[[ $firewallallowProtocol == "" ]] && firewallallowProtocol="all"
 
echo $networkName
gcloud compute networks create $networkName --subnet-mode custom --bgp-routing-mode  regional 
gcloud compute networks subnets create $subnetName --network=$networkName --range=$ipcidrRange &&  \
gcloud compute firewall-rules create $firewallruleName --network $networkName --allow $firewallallowProtocol --direction ingress --priority  100 

```
- check the result

`gcloud compute networks list --format json`
```
[
  {
    "autoCreateSubnetworks": false,
    "creationTimestamp": "2023-05-15T19:29:51.132-07:00",
    "id": "2853168068019836016",
    "kind": "compute#network",
    "name": "gkenetwork1",
    "networkFirewallPolicyEnforcementOrder": "AFTER_CLASSIC_FIREWALL",
    "routingConfig": {
      "routingMode": "REGIONAL"
    },
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "selfLinkWithId": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/2853168068019836016",
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
    "creationTimestamp": "2023-05-15T19:30:04.959-07:00",
    "fingerprint": "wZDnvad88r0=",
    "gatewayAddress": "10.0.0.1",
    "id": "4940901015761146947",
    "ipCidrRange": "10.0.0.0/24",
    "kind": "compute#subnetwork",
    "name": "gkenode",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "privateIpGoogleAccess": true,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1",
    "secondaryIpRanges": [
      {
        "ipCidrRange": "10.144.0.0/20",
        "rangeName": "gke-my-first-cluster-1-services-ece0bc06"
      },
      {
        "ipCidrRange": "10.140.0.0/14",
        "rangeName": "gke-my-first-cluster-1-pods-ece0bc06"
      }
    ],
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/asia-east1/subnetworks/gkenode",
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
        "IPProtocol": "sctp"
      },
      {
        "IPProtocol": "tcp"
      },
      {
        "IPProtocol": "udp"
      },
      {
        "IPProtocol": "icmp"
      },
      {
        "IPProtocol": "esp"
      },
      {
        "IPProtocol": "ah"
      }
    ],
    "creationTimestamp": "2023-05-15T19:31:35.771-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "3395271920928642536",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-ece0bc06-all",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-ece0bc06-all",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-ece0bc06-node"
    ]
  },
  {
    "creationTimestamp": "2023-05-15T19:31:35.727-07:00",
    "denied": [
      {
        "IPProtocol": "tcp",
        "ports": [
          "10255"
        ]
      }
    ],
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "7385047447989343720",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-ece0bc06-exkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-ece0bc06-exkubelet",
    "sourceRanges": [
      "0.0.0.0/0"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-ece0bc06-node"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "tcp",
        "ports": [
          "10255"
        ]
      }
    ],
    "creationTimestamp": "2023-05-15T19:31:35.830-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "8256475236943222248",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-ece0bc06-inkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 999,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-ece0bc06-inkubelet",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "sourceTags": [
      "gke-my-first-cluster-1-ece0bc06-node"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-ece0bc06-node"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "icmp"
      },
      {
        "IPProtocol": "tcp",
        "ports": [
          "1-65535"
        ]
      },
      {
        "IPProtocol": "udp",
        "ports": [
          "1-65535"
        ]
      }
    ],
    "creationTimestamp": "2023-05-15T19:31:36.151-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "359073794659145191",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-ece0bc06-vms",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-ece0bc06-vms",
    "sourceRanges": [
      "10.0.0.0/24"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-ece0bc06-node"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "all"
      }
    ],
    "creationTimestamp": "2023-05-15T19:30:28.366-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "6172856038942790699",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gkenetwork1-allow-custom",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 100,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gkenetwork1-allow-custom",
    "sourceRanges": [
      "0.0.0.0/0"
    ]
  }
]
```
- create gke cluster 

create gke cluster 
*enable-ip-alias* to enable use alias ip on VM for pod ip address
*service-ipv4-cidr* is for clusterVIP address
*cluster-ipv4-cidr* is for POD ip address scope

- paste below command to create gke cluster 
```
#!/bin/bash -xe
[[ $defaultClustername == "" ]] && defaultClustername="my-first-cluster-1"
[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"
[[ $machineType == "" ]] && machineType="g1-small"
[[ $num_nodes == "" ]] && num_nodes="1"

gkeClusterName=$defaultClustername
machineType=$machineType
gkeNetworkName=$(gcloud compute networks list --format="value(name)" --filter="name="$networkName""  --limit=1)
gkeSubnetworkName=$(gcloud compute networks subnets  list --format="value(name)" --filter="name="$subnetName"" --limit=1)

projectName=$(gcloud config list --format="value(core.project)") && \
region=$(gcloud compute networks subnets list --format="value(region)" --limit=1) && \

gcloud services enable container.googleapis.com  && \

gcloud beta container clusters create $gkeClusterName  \
	--no-enable-basic-auth \
	--cluster-version "1.26.3-gke.1000" \
	--release-channel "rapid" \
	--machine-type $machineType \
	--image-type "UBUNTU_CONTAINERD" \
	--disk-type "pd-balanced" \
	--disk-size "32" \
	--metadata disable-legacy-endpoints=true \
	--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
	--max-pods-per-node "110" \
	--num-nodes $num_nodes \
	--enable-ip-alias \
	--network "projects/$projectName/global/networks/$gkeNetworkName" \
	--subnetwork "projects/$projectName/regions/$region/subnetworks/$gkeSubnetworkName" \
       	--no-enable-intra-node-visibility \
	--default-max-pods-per-node "110" \
	--no-enable-master-authorized-networks \
	--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
	--enable-autoupgrade \
	--enable-autorepair \
       	--max-surge-upgrade 1 \
	--max-unavailable-upgrade 0 \
	--enable-shielded-nodes \
	--services-ipv4-cidr 10.144.0.0/20 \
        --cluster-ipv4-cidr  10.140.0.0/14

echo done
echo cluster has podIpv4CidrBlock $(gcloud container clusters describe $gkeClusterName --format="value(nodePools.networkConfig.podIpv4CidrBlock)")
echo cluster has servicesIpv4Cidr $(gcloud container clusters describe $gkeClusterName --format="value(servicesIpv4Cidr)")


clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1)
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1)
echo cluster worker node vm has internal ip $(gcloud compute instances describe $name --format="value(networkInterfaces.aliasIpRanges)" --format="value(networkInterfaces.networkIP)")
echo cluster worker node vm has alias ip $(gcloud compute instances describe $name  --format="value(networkInterfaces.aliasIpRanges)")
```
- check the result
`kubectl get node -o wide`
```
NAME                                                STATUS   ROLES    AGE   VERSION            INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
gke-my-first-cluster-1-default-pool-cd44c9ff-hr67   Ready    <none>   34s   v1.26.3-gke.1000   10.0.0.4      34.80.212.63     Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
gke-my-first-cluster-1-default-pool-cd44c9ff-td6v   Ready    <none>   31s   v1.26.3-gke.1000   10.0.0.3      35.189.160.192   Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
```
- enable worker node ipforwarding 

by default, the GKE come with ipforwarding disabled. for cFOS to work. we have to enable ip forwarding on worker node.
to enable ipforwarding, we need to config *canIpForward: true* for instance profile, for more detail , check  https://cloud.google.com/vpc/docs/using-routes#canipforward.

- paste below command to enable ipforwarding 
```
[[ $defaultClustername == "" ]] && defaultClustername="my-first-cluster-1"
gkeClusterName=$defaultClustername
clustersearchstring=$(gcloud container clusters list --filter=name=$gkeClusterName --format="value(name)" --limit=1)
node_list=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" )
projectName=$(gcloud config list --format="value(core.project)")
zone=$(gcloud config list --format="value(compute.zone)" --limit=1)

for name in $node_list; do {

gcloud compute instances export $name \
    --project $projectName \
    --zone $zone \
    --destination=./$name.txt
grep -q "canIpForward: true" $name.txt || sed -i '/networkInterfaces/i canIpForward: true' $name.txt
sed '/networkInterfaces/i canIpForward: true' $name.txt 
gcloud compute instances update-from-file $name\
    --project $projectName \
    --zone $zone \
    --source=$name.txt \
    --most-disruptive-allowed-action=REFRESH
echo "done for $name"
}
done
```
- install multus cni 

We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, 
the default multus config will use *"--multus-conf-file=auto"*, with this option. multus will automatically create 00-multus.conf file with delegate to default 10-containerd-net.conflist. in this demo. we use default behavior. 
we  need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission.
each worker node will have one multus POD installed. 
- paste below command to install multus CNI with manual config 
```
file="multus_auto.yml"
#multusconfig="/tmp/multus-conf/07-multus.conf" 
multusconfig="auto"
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
            path: /home/kubernetes/bin
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
2023-05-16T00:41:17+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-05-16T00:41:17+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
```
- create net-attach-def for cfos  
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for cfos to attach. 
the cni config of macvlan use bridge mode and associated with "ens4" interface on worker node. if the master interface on worker node is other than ens4. you need change that.
you can ssh into worker node to check master interface name. 
the net-attach-def has name "cfosdefaultcni5". 
- paste below command to create net-attach-def
```
filename="04_nad_macvlan_cfos.yml"
master_interface_on_worker_node="ens4"
cat << EOF > $filename
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: cfosdefaultcni5
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


```
- check the result
`kubectl get net-attach-def cfosdefaultcni5 -o yaml `
```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  creationTimestamp: "2023-05-16T00:41:20Z"
  generation: 1
  name: cfosdefaultcni5
  namespace: default
  resourceVersion: "2557"
  uid: a38a6faa-a593-43f5-b7e1-43f58ac7fd84
spec:
  config: '{ "cniVersion": "0.3.1", "type": "macvlan", "master": "ens4", "mode": "bridge",
    "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "rangeStart": "10.1.200.250",
    "rangeEnd": "10.1.200.253", "gateway": "10.1.200.1" } }'
```
- create net-attach-def for application deployment  
We will create net-attach-def with mac-vlan CNI ,multus CNI will use this net-attach-def to create  network and attach POD to the network.
We use host-local as IPAM CNI. this net-attach-def is for application to attach. 
the cni config of macvlan use bridge mode and associated with "ens4" interface on worker node. if the master interface on worker node is other than ens4. you need change that.
you can ssh into worker node to check master interface name. 
the net-attach-def has name "cfosapp".  we also use "cfosapp" as label in policy manager demo. if you change this name to something  else, you will also need to change the image for policy manager where cfosapp is hard coded in the image script. 
- paste below command to create net-attach-def
```
filename="04_nad_macvlan_for_app.yml"
master_interface_on_worker_node="ens4"
dst1='{ "dst": "1.1.1.1/32", "gw": "10.1.200.252" },'
dst2='{ "dst": "104.18.0.0/16", "gw": "10.1.200.252"},'
lastdst='{ "dst": "89.238.73.0/24", "gw": "10.1.200.252"}'

app_nad_annotation="cfosapp"
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
        "subnet": "10.1.200.0/24",
        "routes": [
          $dst1
          $dst2
          $lastdst
        ],
        "rangeStart": "10.1.200.20",
        "rangeEnd": "10.1.200.251",
        "gateway": "10.1.200.1"
      }
    }'
EOF
kubectl create -f $filename && kubectl rollout status ds/kube-multus-ds -n kube-system  && echo "done"
kubectl get net-attach-def $app_nad_annotation -o yaml

```
- check the result
`kubectl get net-attach-def cfosapp -o yaml `
```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  creationTimestamp: "2023-05-16T00:41:20Z"
  generation: 1
  name: cfosapp
  namespace: default
  resourceVersion: "2561"
  uid: 307e15f8-210a-4706-ab18-2bc1bc94a365
spec:
  config: '{ "cniVersion": "0.3.1", "type": "macvlan", "master": "ens4", "mode": "bridge",
    "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "routes": [ { "dst":
    "1.1.1.1/32", "gw": "10.1.200.252" }, { "dst": "104.18.0.0/16", "gw": "10.1.200.252"},
    { "dst": "89.238.73.0/24", "gw": "10.1.200.252"} ], "rangeStart": "10.1.200.20",
    "rangeEnd": "10.1.200.251", "gateway": "10.1.200.1" } }'
```
- create demo application deployment

we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp" } ]'* to config to POD for secondary interface and custom route entry.
we did not touch pod default route, instead we only insert custom route that we are interested. so for destination, the next hop will be cFOS. cFOS will inspect traffic for those traffic.
we configured ip address 1.1.1.1/32 , 89.238.73.0/24 , 104.18.0.0/16 route point to cFOS for inspection in this demo. 

- paste below command to create application deployment
```
file="app_with_annotations_cfosapp.yml"
annotations="k8s.v1.cni.cncf.io/networks: '[ { \"name\": \"cfosapp\" } ]'"
cat << EOF > $file 
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
        $annotations
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF

kubectl create -f $file && kubectl rollout status deployment multitool01-deployment
```
- check the result
`kubectl rollout status deployment multitool01-deployment`
```
deployment "multitool01-deployment" successfully rolled out
```
`kubectl get pod -l app=multitool01`
```
NAME                                      READY   STATUS    RESTARTS   AGE
multitool01-deployment-7f5bf4b7cd-74mm4   1/1     Running   0          7s
multitool01-deployment-7f5bf4b7cd-fgs4s   1/1     Running   0          7s
multitool01-deployment-7f5bf4b7cd-gpgxq   1/1     Running   0          7s
multitool01-deployment-7f5bf4b7cd-wj8xd   1/1     Running   0          7s
```
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.1.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.20 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.9 
10.140.1.1 dev eth0 scope link src 10.140.1.9 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 5e:fc:0e:ca:74:c9 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.9/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether a2:1a:4b:36:eb:ce brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.20/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.0.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.20 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.5 
10.140.0.1 dev eth0 scope link src 10.140.0.5 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 46:38:f5:26:7c:9e brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.5/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 3e:c0:e9:3a:92:8f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.20/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
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
read-configmaps   ClusterRole/configmap-reader   0s
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2023-05-16T00:41:31Z"
  name: read-secrets
  namespace: default
  resourceVersion: "2711"
  uid: c31edb43-2fbd-4487-92b9-46b52f67b38a
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: secrets-reader
subjects:
- kind: ServiceAccount
  name: default
```
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
file="cfos_ds.yml" 

cat << EOF > $file
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

kubectl create -f $file  && \

kubectl rollout status ds/fos-deployment && kubectl get pod -l app=fos
```
- check the result
`
kubectl rollout status ds/fos-deployment && kubectl get pod -l app=fos
`
```
daemon set "fos-deployment" successfully rolled out
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-d9dz5   1/1     Running   0          8s
fos-deployment-r9t9r   1/1     Running   0          8s
```
check routing table and ip address
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.1.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.11 
10.140.1.1 dev eth0 scope link src 10.140.1.11 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether e2:93:2f:c4:24:24 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.11/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.0.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.7 
10.140.0.1 dev eth0 scope link src 10.140.0.7 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 06:28:ee:82:51:43 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.7/24 brd 10.140.0.255 scope global eth0
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
INFO: 2023/05/16 00:41:40 importing license...
INFO: 2023/05/16 00:41:41 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/05/16 00:41:40 importing license...
INFO: 2023/05/16 00:41:40 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
```
- create configmap for cfos to get firewall policy configuration 
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS
there is an issue in this version, the configuration applied via configmap will not take effect until you restart cFOS DS.
the firewall policy has policy id set to 300 and source address set to any

- paste below command to create configmap that include firewall policy configuration
```
policy_id="300"
file="configmapfirewallpolicy.yml"
cat << EOF > $file
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
           edit "$policy_id"
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
kubectl create -f $file 
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
  creationTimestamp: "2023-05-16T00:41:43Z"
  labels:
    app: fos
    category: config
  name: foscfgfirewallpolicy
  namespace: default
  resourceVersion: "2853"
  uid: b2f862f9-e9f6-433c-99bd-718246e125ab
```
check cfos log for retrive config from configmap
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl logs po/$podName ; done
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/05/16 00:41:40 importing license...
INFO: 2023/05/16 00:41:41 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/05/16 00:41:40 importing license...
INFO: 2023/05/16 00:41:40 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-05-16_00:41:41.78935 ok: run: /run/fcn_service/certd: (pid 276) 0s, normally down
```
- restart cfos DaemonSet  to workaround policy not work issue 
when use configmap to apply firewallpolicy to cFOS, if it's the first time to config cFOS using firewall policy, then a restart cFOS is required


- paste below command to restart cFOS DaemonSet 
```
kubectl rollout status ds/fos-deployment && \
kubectl rollout restart ds/fos-deployment && \
kubectl rollout status ds/fos-deployment && \
podname=$(kubectl get pod -l app=fos  | grep Running | grep fos | cut -d " " -f 1) && \
echo 'check cfos iptables for snat entry' && \
kubectl exec -it po/$podname -- iptables -L -t nat --verbose | grep MASQ && \
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
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ;  kubectl exec -it po/$podName -- iptables -L -t nat --verbose | grep MASQ ; done
`
```
   27  2248 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
```
- do a ips test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the IPS signature. if match the signature. cFOS can either block it or pass it with alert depends on the policy configured.

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will exepct to see ips traffic log with matched firewall policy id to indicate which policy is in action.

- paste below command to send malicous traffic from application pod 
```
url="www.hackthebox.eu"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- dig $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c 2  $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$url ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 300  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 300 ; done
`
```
date=2023-05-16 time=00:43:20 eventtime=1684197800 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=46940 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743681 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:43:25 eventtime=1684197805 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=55104 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743682 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:43:10 eventtime=1684197790 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=4 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=52758 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460609 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:43:15 eventtime=1684197795 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=50658 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460610 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
- do a web filter  test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will expect to see web filter log with matched policy id to indicate which firewall policy is in action
- paste below command initial access to the target website 
```
url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 300 ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 300 ; done
`
```
date=2023-05-16 time=00:43:36 eventtime=1684197816 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=4 srcip=10.1.200.20 srcport=52148 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:43:36 eventtime=1684197816 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.21 srcport=51020 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:43:33 eventtime=1684197813 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=4 srcip=10.1.200.20 srcport=54018 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:43:34 eventtime=1684197814 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=8 srcip=10.1.200.21 srcport=54880 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
- use cfos restful API to delete firewall policy 
we can use cFOS shell to change firewall policy, we can also use cFOS restAPI to do the same. 
after delete firewall policy, ping to 1.1.1.1 from application pod will no longer reachable
- paste below command delete firewall policy 
```
policy_id="300"
#url="http://fos-deployment.default.svc.cluster.local"
nodeList=$(kubectl get pod -l app=fos -o jsonpath='{.items[*].status.podIP}')
kubectl delete cm foscfgfirewallpolicy
echo $nodeList
for i in $nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/$policy_id"
}
done
```
- check the result
`
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
`
```
pod multitool01-deployment-7f5bf4b7cd-74mm4
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.53 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.533/4.533/4.533/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-fgs4s
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=3.55 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.548/3.548/3.548/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-gpgxq
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=5.41 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.412/5.412/5.412/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-wj8xd
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.48 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.480/4.480/4.480/0.000 ms
```
- create an POD to update POD source IP to cFOS 
POD IPs are keep changing due to scale in/out or reborn , deleting etc for various reason, we need to keep update the POD ip address to cFOS address group. 
we create a POD dedicated for this. this POD keep running a background proces which update the application POD's IP  that has annoation to net-attach-def "cfosapp" to cFOS via cFOS restful API. 
the API call to cFOS can use either cFOS dns name or cFOS node IPs. if cFOS use shared storage for configuration, then use dns name is proper way, otherwise, we will need to update each cFOS POD directly via CFOS POD ip address. the policy_manager by default using cFOS POD ip address. 

the policy_manager pod use image from *interbeing/kubectl-cfos:gke_demo_v1*
the source code of this image is under policymanager/
build.sh  Dockerfile  script.sh
you can build by yourself. 
- paste below command to create policy_manager 
```
filename="18_cfospolicymanager.yml"
policymanagerimage="interbeing/kubectl-cfos:gke_demo_v1"

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
    #- apiGroups: [""]
    #  resources: ["pods/exec"]
    #  verbs: ["create"]
    #

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
EOF
kubectl apply -f $filename  && wait_for_pod_ready && kubectl exec -it po/policymanager -- curl -X GET "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy" && kubectl exec -it po/policymanager -- curl -X GET "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp" 

```
- check the result
`
kubectl get pod policymanager && kubectl exec -it po/policymanager -- curl -X GET "http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp"
`
```
NAME            READY   STATUS    RESTARTS   AGE
policymanager   1/1     Running   0          44m
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
          "name": "none"
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
}\n
```
- do a ips test on a target website
we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is 101
- paste below command to send malicous traffic from application pod 
```
url="www.hackthebox.eu"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- dig $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c 2  $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$url ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 101 ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 101 ; done
`
```
date=2023-05-16 time=00:44:09 eventtime=1684197849 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=12 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=33424 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743683 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:44:14 eventtime=1684197854 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=14 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=50370 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743684 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:43:59 eventtime=1684197839 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=11 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=58188 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460611 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:44:04 eventtime=1684197844 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=9 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=52722 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460612 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
- do a web filter  test on a target website
same to web fitler traffic
- paste below command initial access to the target website 
```
url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 101  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 101  ; done
`
```
date=2023-05-16 time=00:44:24 eventtime=1684197864 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=9 srcip=10.1.200.20 srcport=49258 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:44:25 eventtime=1684197865 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=16 srcip=10.1.200.21 srcport=56348 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:44:22 eventtime=1684197862 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=11 srcip=10.1.200.20 srcport=46532 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:44:23 eventtime=1684197863 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=13 srcip=10.1.200.21 srcport=51054 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
- modify worker node default CNI confige

in previous section, we did not touch application POD's default route, only we interested destination like 1.1.1.1 is send to cFOS, what about if want send all traffic from application POD to cFOS, we will need then insert a default route into application pod, for this purpose, we will need use keyword default-route in the annotation part of POD definition. but this is not enough. as you still want some other traffic continue to go to default interface instead goes to cFOS, for example, the traffic goes to gke cluster IP and cross POD to POD traffic. so also need modify the default GKE cni config to insert custom route. 

- paste below command to modify default GKE cni config to insert route 
```
#!/bin/bash 
clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) && \
namelist=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" ) && \
for name in $namelist ; do {

route_exists=$(gcloud compute ssh $name --command="sudo grep -E '\"dst\": \"10.144.0.0\\/20\"|\"dst\": \"10.140.0.0\\/14\"' /etc/cni/net.d/10-containerd-net.conflist")
if [ -z "$route_exists" ]; then
  gcloud compute ssh $name --command="sudo sed -i '/\"dst\": \"0.0.0.0\\/0\"/!b;n;N;s/        \\]$/,\n          {\"dst\": \"10.144.0.0\\/20\"},\n          {\"dst\": \"10.140.0.0\\/14\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"
kubectl rollout restart ds/kube-multus-ds -n kube-system && 
kubectl rollout status ds/kube-multus-ds -n kube-system 
kubectl logs  ds/kube-multus-ds -n kube-system
fi


 #gcloud compute ssh $name --command="sudo sed -i '/\"dst\": \"0.0.0.0\\/0\"/!b;n;N;s/        \\]$/,\n          {\"dst\": \"10.144.0.0\\/20\"},\n          {\"dst\": \"10.140.0.0\\/14\"}\n        ]/' /etc/cni/net.d/10-containerd-net.conflist"


#gcloud compute ssh $name --command="sudo cat /etc/cni/net.d/10-containerd-net.conflist"
#gcloud compute ssh $name --command='sudo cat /etc/cni/net.d/00-multus.conf' 
kubectl logs  ds/kube-multus-ds -n kube-system
}
done
```
- check the result
`
kubectl logs ds/kube-multus-ds -n kube-system
`
```
2023-05-16T00:45:18+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-05-16T00:45:19+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-05-16T00:45:21+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-05-16T00:45:21+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
2023-05-16T00:45:22+00:00 Config file created @ /host/etc/cni/net.d/00-multus.conf
{ "cniVersion": "0.3.1", "name": "multus-cni-network", "type": "multus", "capabilities": {"portMappings": true}, "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig", "delegates": [ { "name": "k8s-pod-network", "cniVersion": "0.3.1", "plugins": [ { "type": "ptp", "mtu": 1460, "ipam": { "type": "host-local", "subnet": "10.140.0.0/24", "routes": [ { "dst": "0.0.0.0/0" } , {"dst": "10.144.0.0/20"}, {"dst": "10.140.0.0/14"} ] } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] } ] }
2023-05-16T00:45:22+00:00 Entering sleep (success)...
```
- delete current appliation deployment 

- paste below command to delete 
```
kubectl get deployment multitool01-deployment && kubectl delete deployment multitool01-deployment
```
- create application deployment 

create deployment with annotation to use net-attach-def and also config default route point to net-attach-def attached interface. which is cFOS interface. 
the annotation field has context 
*k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp",  "default-route": ["10.1.200.252"]  } ]'* , which config an default route with nexthop to 10.1.200.252.
check ip route table on application shall see the default route point to cFOS interface. 
- paste below command to create deployment 
```
file="app_with_annotations_cfosapp_with_defalt_route.yml"
cat << EOF > $file 
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
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp",  "default-route": ["10.1.200.252"]  } ]' 
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF

kubectl create -f $file && kubectl rollout status deployment multitool01-deployment
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
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.14 
10.140.1.1 dev eth0 scope link src 10.140.1.14 
10.144.0.0/20 via 10.140.1.1 dev eth0 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 82:ec:bc:79:57:bd brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.14/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether b2:14:bf:79:23:c5 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.23/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.1.200.252 dev net1 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.23 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10 
10.140.0.0/14 via 10.140.0.1 dev eth0 
10.140.0.1 dev eth0 scope link src 10.140.0.10 
10.144.0.0/20 via 10.140.0.1 dev eth0 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 7a:0b:78:32:03:ca brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.10/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether c6:2f:48:c9:10:08 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.23/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
- do a web filter  test on a target website
this time we ,use destination that not on match default route, for example "https://xoso.com.vn". this website will be classified by cFOS as Gambling that shall be blocked by default profile.

- paste below command initial access to the target website 
```
url="https://xoso.com.vn"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 101  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep 101  ; done
`
```
date=2023-05-16 time=00:44:24 eventtime=1684197864 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=9 srcip=10.1.200.20 srcport=49258 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:44:25 eventtime=1684197865 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=16 srcip=10.1.200.21 srcport=56348 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:47:52 eventtime=1684198072 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=18 srcip=10.1.200.23 srcport=40486 srcintf="net1" dstip=104.18.24.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-05-16 time=00:47:52 eventtime=1684198072 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=20 srcip=10.1.200.22 srcport=34002 srcintf="net1" dstip=104.18.24.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-05-16 time=00:44:22 eventtime=1684197862 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=11 srcip=10.1.200.20 srcport=46532 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:44:23 eventtime=1684197863 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=13 srcip=10.1.200.21 srcport=51054 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:47:51 eventtime=1684198071 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=13 srcip=10.1.200.23 srcport=56156 srcintf="net1" dstip=104.18.25.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
date=2023-05-16 time=00:47:52 eventtime=1684198072 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=17 srcip=10.1.200.22 srcport=34302 srcintf="net1" dstip=104.18.24.243 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="xoso.com.vn" profile="default" action="blocked" reqtype="direct" url="https://xoso.com.vn/" sentbyte=106 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=11 catdesc="Gambling"
```
- use cfos restful API to delete firewall policy 
the policy created by policy_manager pod has policy id 101, let us delete this firewall policy use cfosrestapi. 
after delete firewall policy, we use crl to check whether any firewall policy left on cFOS POD
- paste below command delete firewall policy 
```
policy_id="101"
#url="http://fos-deployment.default.svc.cluster.local"
nodeList=$(kubectl get pod -l app=fos -o jsonpath='{.items[*].status.podIP}')
#kubectl delete cm foscfgfirewallpolicy
echo $nodeList
for i in $nodeList; do {
kubectl exec -it po/policymanager -- curl -X DELETE "$i/api/v2/cmdb/firewall/policy/$policy_id"
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
}\n
```
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
check routing table and ip address
`
kubectl get constrainttemplates -o yaml
`
```
apiVersion: v1
items:
- apiVersion: templates.gatekeeper.sh/v1
  kind: ConstraintTemplate
  metadata:
    creationTimestamp: "2023-05-16T00:48:12Z"
    generation: 1
    name: k8segressnetworkpolicytocfosutmpolicy
    resourceVersion: "6526"
    uid: 799104f8-d85a-40ae-a903-b8a0a59e2471
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
      id: gatekeeper-controller-manager-5db7c8878c-wl9q2
      observedGeneration: 1
      operations:
      - mutation-webhook
      - webhook
      templateUID: 799104f8-d85a-40ae-a903-b8a0a59e2471
    created: false
kind: List
metadata:
  resourceVersion: ""
```
- create standard networkpolicy   
here we create reguard k8s egress networkpolicy, this policy will be created on cFOS with gatekeeper help. 
after creating. use "kubectl get networkpolicy will not show you the policy" as it actually created on cFOS. 
instead , you can get policy by use cFOS API with command *kubectl exec -it po/policymanager -- curl -X GET http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy*
- paste below command to deploy networkpolicy 
```
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

node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $node_list;  do 
       {
	kubectl apply -f $filename
	kubectl apply -f $filename
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
}\n
```
- do a ips test on a target website
we do ips test again, this time, the policy created by policymanager will take the action. we can chech the ips log to prove it. the traffic shall match different policy ID which is 200
- paste below command to send malicous traffic from application pod 
```
url="www.hackthebox.eu"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- dig $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c 2  $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$url ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep 200 ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0 | grep policyid=200 ; done
`
```
date=2023-05-16 time=00:48:42 eventtime=1684198122 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.25 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=4 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=39726 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743685 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:48:53 eventtime=1684198133 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.24 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=2 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=56218 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=188743686 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:48:48 eventtime=1684198128 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.24 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=49518 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460613 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-16 time=00:48:58 eventtime=1684198138 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.25 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=200 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=59048 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=139460614 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
- install gatekeeperv3 
We will use standard k8s networkpolicy to create firewallpolicy for cFOS, the networkpolicy submitted by kubectl will first be send to gatekeeper admission controller. where there is a constraint delpoyed to inspect the policy constraint via constraint template. if the networkpolicy pass the constrait check. the constraint template will use cFOS Restapi to create firewall policy. and then the constraint template will give output telling the networkpolicy creation is forbiden instead it created on CFOS. 

- paste below command to install gatekeeper 
```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml && \
kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system &&  \
kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system  && kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system



```
- check the result
check routing table and ip address
`
kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system &&  kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system  && kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system
`
```
deployment "gatekeeper-audit" successfully rolled out
deployment "gatekeeper-controller-manager" successfully rolled out
deployment "gatekeeper-audit" successfully rolled out
```
- install policy constraint   

the policy constraint mainly function as parameter input to constraint template. here for example, use pass in policy id=200 for constraint template. we also pass in cFOS restAPI URL etc., 
beaware that here we are using dns name of clusterIP for cFOS API, if we are not using shared  storage for cFOS /data folder, we need run API call multiple times to make sure it config each of cFOS POD. 

- paste below command to install policy constraint template 
```
filename="48_constraint_for_cfos.yml"
cat << EOF >$filename
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

kubectl apply -f $filename && kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml
```
- check the result
check routing table and ip address
`
kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml
`
```
apiVersion: v1
items:
- apiVersion: constraints.gatekeeper.sh/v1beta1
  kind: K8sEgressNetworkPolicyToCfosUtmPolicy
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"constraints.gatekeeper.sh/v1beta1","kind":"K8sEgressNetworkPolicyToCfosUtmPolicy","metadata":{"annotations":{},"name":"cfosnetworkpolicy"},"spec":{"enforcementAction":"deny","match":{"kinds":[{"apiGroups":["networking.k8s.io"],"kinds":["NetworkPolicy"]}]},"parameters":{"action":"permit","avprofile":"default","extraservice":"PING","firewalladdressapiurl":"http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address","firewalladdressgrpapiurl":"http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp","firewallpolicyapiurl":"http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy","ipsprofile":"default","label":"cfosegressfirewallpolicy","outgoingport":"eth0","policyid":"200","srcintf":"any","sslsshprofile":"deep-inspection","utmstatus":"enable"}}}
    creationTimestamp: "2023-05-16T00:48:14Z"
    generation: 1
    name: cfosnetworkpolicy
    resourceVersion: "6552"
    uid: effe6d7c-2a95-4d40-baf7-ba3bdbb9a785
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
    - constraintUID: effe6d7c-2a95-4d40-baf7-ba3bdbb9a785
      enforced: true
      id: gatekeeper-audit-94c9bfc9b-x5gk8
      observedGeneration: 1
      operations:
      - audit
      - mutation-status
      - status
    - constraintUID: effe6d7c-2a95-4d40-baf7-ba3bdbb9a785
      enforced: true
      id: gatekeeper-controller-manager-5db7c8878c-gvwcv
      observedGeneration: 1
      operations:
      - mutation-webhook
      - webhook
kind: List
metadata:
  resourceVersion: ""
```
- restart application deployment to trigger policymanager update addressgrp in cFOS 
due to limitation of policymanager, it require pod ip change to trigger update addressgrp in cFOS, we can restar application pod, scale in, scale out etc to force pod IP change. 
you can use "kubectl logs -f po/policymanager" to check the log of policymanager 

- paste below command to restart appliation DaemonSet 
```
kubectl rollout restart deployment multitool01-deployment && kubectl rollout status deployment multitool01-deployment
```
- check the result
`
kubectl rollout status deployment multitool01-deployment
`
```
deployment "multitool01-deployment" successfully rolled out
```
- do a web filter  test on a target website
same to web fitler traffic
- paste below command initial access to the target website 
```
url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=200  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0 | grep policyid=200  ; done
`
```
date=2023-05-16 time=00:49:05 eventtime=1684198145 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=4 srcip=10.1.200.25 srcport=47410 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:49:07 eventtime=1684198147 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=6 srcip=10.1.200.24 srcport=38546 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:49:06 eventtime=1684198146 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=5 srcip=10.1.200.24 srcport=54890 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-16 time=00:49:08 eventtime=1684198148 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=200 sessionid=5 srcip=10.1.200.25 srcport=44980 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
