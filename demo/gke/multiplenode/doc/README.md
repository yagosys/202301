- create network for gke cluster 

create network for GKE VM instances.
the *ipcidrRange* is the ip range for VM node. 
the *firewallallowProtocol="tcp:22* allow ssh into worker node from anywhere 
- paste below command to create network 
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
    "creationTimestamp": "2023-05-14T02:13:50.861-07:00",
    "id": "2652305847883733153",
    "kind": "compute#network",
    "name": "gkenetwork1",
    "networkFirewallPolicyEnforcementOrder": "AFTER_CLASSIC_FIREWALL",
    "routingConfig": {
      "routingMode": "REGIONAL"
    },
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "selfLinkWithId": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/2652305847883733153",
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
    "creationTimestamp": "2023-05-14T02:14:05.840-07:00",
    "fingerprint": "_YWrvbFB-2Y=",
    "gatewayAddress": "10.0.0.1",
    "id": "3694786516196595890",
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
        "ipCidrRange": "10.140.0.0/14",
        "rangeName": "gke-my-first-cluster-1-pods-60c15a01"
      },
      {
        "ipCidrRange": "10.144.0.0/20",
        "rangeName": "gke-my-first-cluster-1-services-60c15a01"
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
        "IPProtocol": "icmp"
      },
      {
        "IPProtocol": "esp"
      },
      {
        "IPProtocol": "ah"
      },
      {
        "IPProtocol": "sctp"
      },
      {
        "IPProtocol": "tcp"
      },
      {
        "IPProtocol": "udp"
      }
    ],
    "creationTimestamp": "2023-05-14T02:15:35.398-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "1023899045196535896",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-60c15a01-all",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-60c15a01-all",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-60c15a01-node"
    ]
  },
  {
    "creationTimestamp": "2023-05-14T02:15:35.352-07:00",
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
    "id": "356326536007981144",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-60c15a01-exkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-60c15a01-exkubelet",
    "sourceRanges": [
      "0.0.0.0/0"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-60c15a01-node"
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
    "creationTimestamp": "2023-05-14T02:15:35.346-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "7431194848655120472",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-60c15a01-inkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 999,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-60c15a01-inkubelet",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "sourceTags": [
      "gke-my-first-cluster-1-60c15a01-node"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-60c15a01-node"
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
    "creationTimestamp": "2023-05-14T02:15:35.724-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "5066813758774253656",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-60c15a01-vms",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-60c15a01-vms",
    "sourceRanges": [
      "10.0.0.0/24"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-60c15a01-node"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "all"
      }
    ],
    "creationTimestamp": "2023-05-14T02:14:23.899-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "6662533605481060480",
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
NAME                                                STATUS   ROLES    AGE    VERSION            INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
gke-my-first-cluster-1-default-pool-153a6423-00rx   Ready    <none>   5m8s   v1.26.3-gke.1000   10.0.0.3      35.189.160.192   Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
gke-my-first-cluster-1-default-pool-153a6423-px6g   Ready    <none>   5m5s   v1.26.3-gke.1000   10.0.0.4      34.80.212.63     Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
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
                "routes": [
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
        #- "--multus-conf-file=/tmp/multus-conf/07-multus.conf" 
        - "--multus-conf-file=auto"
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
2023-05-14T09:21:46+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-05-14T09:21:47+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-05-14T09:21:48+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-05-14T09:21:48+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
2023-05-14T09:21:48+00:00 Config file created @ /host/etc/cni/net.d/00-multus.conf
{ "cniVersion": "0.3.1", "name": "multus-cni-network", "type": "multus", "capabilities": {"portMappings": true}, "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig", "delegates": [ { "name": "k8s-pod-network", "cniVersion": "0.3.1", "plugins": [ { "type": "ptp", "mtu": 1460, "ipam": { "type": "host-local", "subnet": "10.140.1.0/24", "routes": [ { "dst": "0.0.0.0/0" } ] } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] } ] }
2023-05-14T09:21:48+00:00 Entering sleep (success)...
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
  creationTimestamp: "2023-05-14T09:21:49Z"
  generation: 1
  name: cfosdefaultcni5
  namespace: default
  resourceVersion: "2020"
  uid: 55fe6fd6-d36e-4b26-8e49-7233ea472b9d
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
  creationTimestamp: "2023-05-14T09:21:50Z"
  generation: 1
  name: cfosapp
  namespace: default
  resourceVersion: "2038"
  uid: 64cb6dea-9643-4c72-9906-8e20db01f019
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
multitool01-deployment-7f5bf4b7cd-25mfp   1/1     Running   0          3m49s
multitool01-deployment-7f5bf4b7cd-6zjt6   1/1     Running   0          3m49s
multitool01-deployment-7f5bf4b7cd-pc4gf   1/1     Running   0          3m49s
multitool01-deployment-7f5bf4b7cd-qf8nm   1/1     Running   0          3m49s
```
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.0.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.21 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10 
10.140.0.1 dev eth0 scope link src 10.140.0.10 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether e2:f5:c3:6e:f6:2e brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.10/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 4e:04:ec:44:d0:ba brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.21/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.1.1 dev eth0 
1.1.1.1 via 10.1.200.252 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.21 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.6 
10.140.1.1 dev eth0 scope link src 10.140.1.6 
89.238.73.0/24 via 10.1.200.252 dev net1 
104.18.0.0/16 via 10.1.200.252 dev net1 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether de:ef:87:9f:63:6f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.6/24 brd 10.140.1.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether fe:a4:e3:7f:3e:3b brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.21/24 brd 10.1.200.255 scope global net1
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
read-configmaps   ClusterRole/configmap-reader   3m43s
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2023-05-14T09:21:59Z"
  name: read-secrets
  namespace: default
  resourceVersion: "2198"
  uid: ffde6923-67d9-4a96-9c9d-9000cb337ba3
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
  sessionAffinity: ClientIP
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
fos-deployment-c5b49   1/1     Running   0          2m23s
fos-deployment-ps446   1/1     Running   0          2m57s
```
check routing table and ip address
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address ; done
`
```
default via 10.140.0.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.12 
10.140.0.1 dev eth0 scope link src 10.140.0.12 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether a6:cf:c6:9d:c2:f6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.12/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
default via 10.140.1.1 dev eth0 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.1.0/24 via 10.140.1.1 dev eth0 src 10.140.1.8 
10.140.1.1 dev eth0 scope link src 10.140.1.8 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether fe:32:87:6d:0b:a4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.1.8/24 brd 10.140.1.255 scope global eth0
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
Starting services...
System is ready.

2023-05-14_09:22:49.48173 ok: run: /run/fcn_service/certd: (pid 257) 1s, normally down
2023-05-14_09:22:54.59567 INFO: 2023/05/14 09:22:54 received a new fos configmap
2023-05-14_09:22:54.59582 INFO: 2023/05/14 09:22:54 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-14_09:22:54.59585 INFO: 2023/05/14 09:22:54 got a fos config
2023-05-14_09:22:54.59649 INFO: 2023/05/14 09:22:54 received a new fos configmap
2023-05-14_09:22:54.59653 INFO: 2023/05/14 09:22:54 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-14_09:22:54.59655 INFO: 2023/05/14 09:22:54 got a fos license

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-14_09:23:23.64673 ok: run: /run/fcn_service/certd: (pid 264) 1s, normally down
2023-05-14_09:23:28.74967 INFO: 2023/05/14 09:23:28 received a new fos configmap
2023-05-14_09:23:28.74976 INFO: 2023/05/14 09:23:28 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-14_09:23:28.74978 INFO: 2023/05/14 09:23:28 got a fos license
2023-05-14_09:23:28.74982 INFO: 2023/05/14 09:23:28 received a new fos configmap
2023-05-14_09:23:28.74984 INFO: 2023/05/14 09:23:28 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-14_09:23:28.74985 INFO: 2023/05/14 09:23:28 got a fos config
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
  creationTimestamp: "2023-05-14T09:22:13Z"
  labels:
    app: fos
    category: config
  name: foscfgfirewallpolicy
  namespace: default
  resourceVersion: "2396"
  uid: 3b374e7d-c75d-4aec-80e1-a335fed76942
```
check cfos log for retrive config from configmap
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in $nodeName; do podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$node" -o jsonpath='{.items[*].metadata.name}') ; kubectl logs po/$podName ; done
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-14_09:22:49.48173 ok: run: /run/fcn_service/certd: (pid 257) 1s, normally down
2023-05-14_09:22:54.59567 INFO: 2023/05/14 09:22:54 received a new fos configmap
2023-05-14_09:22:54.59582 INFO: 2023/05/14 09:22:54 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-14_09:22:54.59585 INFO: 2023/05/14 09:22:54 got a fos config
2023-05-14_09:22:54.59649 INFO: 2023/05/14 09:22:54 received a new fos configmap
2023-05-14_09:22:54.59653 INFO: 2023/05/14 09:22:54 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-14_09:22:54.59655 INFO: 2023/05/14 09:22:54 got a fos license

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-14_09:23:23.64673 ok: run: /run/fcn_service/certd: (pid 264) 1s, normally down
2023-05-14_09:23:28.74967 INFO: 2023/05/14 09:23:28 received a new fos configmap
2023-05-14_09:23:28.74976 INFO: 2023/05/14 09:23:28 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-14_09:23:28.74978 INFO: 2023/05/14 09:23:28 got a fos license
2023-05-14_09:23:28.74982 INFO: 2023/05/14 09:23:28 received a new fos configmap
2023-05-14_09:23:28.74984 INFO: 2023/05/14 09:23:28 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-14_09:23:28.74985 INFO: 2023/05/14 09:23:28 got a fos config
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
   77  6166 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
   64  5156 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
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
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
`
```
date=2023-05-14 time=09:24:53 eventtime=1684056293 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=59098 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520897 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:53 eventtime=1684056293 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=36230 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520898 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:42 eventtime=1684056282 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=47902 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703489 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:47 eventtime=1684056287 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=51376 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703490 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
- do a web filter  test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will expect to see web filter log with matched policy id to indicate which firewall policy is in action
- paste below command initial access to the target website 
```
url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
`
```
date=2023-05-14 time=09:25:12 eventtime=1684056312 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=5 srcip=10.1.200.21 srcport=56866 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:12 eventtime=1684056312 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.20 srcport=53236 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:09 eventtime=1684056309 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.21 srcport=40942 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:10 eventtime=1684056310 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=9 srcip=10.1.200.20 srcport=60654 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
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
pod multitool01-deployment-7f5bf4b7cd-25mfp
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=5.12 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.124/5.124/5.124/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-6zjt6
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.40 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.397/4.397/4.397/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-pc4gf
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=5.01 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.005/5.005/5.005/0.000 ms
pod multitool01-deployment-7f5bf4b7cd-qf8nm
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=4.00 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.996/3.996/3.996/0.000 ms
```
- create an POD to update POD source IP to cFOS 
POD IPs are keep changing due to scale in/out or reborn , deleting etc for various reason, we need to keep update the POD ip address to cFOS address group. 
we create a POD dedicated for this. this POD keep running a background proces which update the application POD's IP  that has annoation to net-attach-def "cfosapp" to cFOS via cFOS restful API. 
the API call to cFOS can use either cFOS dns name or cFOS node IPs. if cFOS use shared storage for configuration, then use dns name is proper way, otherwise, we will need to update each cFOS POD directly via CFOS POD ip address. the policy_manager by default using cFOS POD ip address. 
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
policymanager   1/1     Running   0          53s
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
}```
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
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
`
```
date=2023-05-14 time=09:24:53 eventtime=1684056293 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=59098 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520897 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:53 eventtime=1684056293 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=36230 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520898 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:26:54 eventtime=1684056414 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=10 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=55490 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520899 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:26:59 eventtime=1684056419 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=10 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=54822 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=205520900 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:42 eventtime=1684056282 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=47902 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703489 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:24:47 eventtime=1684056287 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=300 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=51376 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703490 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:26:43 eventtime=1684056403 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.21 dstip=104.18.8.132 srcintf="net1" dstintf="eth0" sessionid=14 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=39980 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703491 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-05-14 time=09:26:48 eventtime=1684056408 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.20 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=101 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=54524 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=144703492 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
- do a web filter  test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will expect to see web filter log with matched policy id to indicate which firewall policy is in action
- paste below command initial access to the target website 
```
url="https://www.eicar.org/download/eicar.com.txt"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  $url  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
`
```
date=2023-05-14 time=09:25:12 eventtime=1684056312 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=5 srcip=10.1.200.21 srcport=56866 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:12 eventtime=1684056312 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.20 srcport=53236 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:27:08 eventtime=1684056428 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=12 srcip=10.1.200.21 srcport=34176 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:27:08 eventtime=1684056428 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=14 srcip=10.1.200.20 srcport=45998 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:09 eventtime=1684056309 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=7 srcip=10.1.200.21 srcport=40942 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:25:10 eventtime=1684056310 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=300 sessionid=9 srcip=10.1.200.20 srcport=60654 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:27:06 eventtime=1684056426 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=16 srcip=10.1.200.21 srcport=35424 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-14 time=09:27:07 eventtime=1684056427 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=18 srcip=10.1.200.20 srcport=53580 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
