 - how to run demo 
 ``` 
source ./variable.sh
./demo.sh
 ``` 
or do it step by step according below procedure 
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
[[ $firewallallowProtocol == "" ]] && firewallallowProtocol="tcp:22"
 
echo $networkName
gcloud compute networks create $networkName --subnet-mode custom --bgp-routing-mode  regional 
gcloud compute networks subnets create $subnetName --network=$networkName --range=$ipcidrRange &&  \
gcloud compute firewall-rules create $firewallruleName --network $networkName --allow $firewallallowProtocol --direction ingress --priority 65534  

```
- check the result
`gcloud compute networks list --format json`
```
[
  {
    "autoCreateSubnetworks": false,
    "creationTimestamp": "2023-05-12T02:42:16.198-07:00",
    "id": "7887406017140733719",
    "kind": "compute#network",
    "name": "gkenetwork1",
    "networkFirewallPolicyEnforcementOrder": "AFTER_CLASSIC_FIREWALL",
    "routingConfig": {
      "routingMode": "REGIONAL"
    },
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "selfLinkWithId": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/7887406017140733719",
    "subnetworks": [
      "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1/subnetworks/gkenode"
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
    "creationTimestamp": "2023-05-12T02:42:27.401-07:00",
    "fingerprint": "Oz61ktNj0eQ=",
    "gatewayAddress": "10.0.0.1",
    "id": "337854023404336364",
    "ipCidrRange": "10.0.0.0/24",
    "kind": "compute#subnetwork",
    "name": "gkenode",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "privateIpGoogleAccess": true,
    "privateIpv6GoogleAccess": "DISABLE_GOOGLE_ACCESS",
    "purpose": "PRIVATE",
    "region": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1",
    "secondaryIpRanges": [
      {
        "ipCidrRange": "10.144.0.0/20",
        "rangeName": "gke-my-first-cluster-1-services-c86fed8d"
      },
      {
        "ipCidrRange": "10.140.0.0/14",
        "rangeName": "gke-my-first-cluster-1-pods-c86fed8d"
      }
    ],
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/regions/us-west1/subnetworks/gkenode",
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
      },
      {
        "IPProtocol": "sctp"
      }
    ],
    "creationTimestamp": "2023-05-12T02:43:31.802-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "4319890685117576364",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-c86fed8d-all",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-c86fed8d-all",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-c86fed8d-node"
    ]
  },
  {
    "creationTimestamp": "2023-05-12T02:43:31.963-07:00",
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
    "id": "812090061527168172",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-c86fed8d-exkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-c86fed8d-exkubelet",
    "sourceRanges": [
      "0.0.0.0/0"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-c86fed8d-node"
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
    "creationTimestamp": "2023-05-12T02:43:31.814-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "221164314637350060",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-c86fed8d-inkubelet",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 999,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-c86fed8d-inkubelet",
    "sourceRanges": [
      "10.140.0.0/14"
    ],
    "sourceTags": [
      "gke-my-first-cluster-1-c86fed8d-node"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-c86fed8d-node"
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
    "creationTimestamp": "2023-05-12T02:43:32.020-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "1174056431921640619",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gke-my-first-cluster-1-c86fed8d-vms",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 1000,
    "selfLink": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/firewalls/gke-my-first-cluster-1-c86fed8d-vms",
    "sourceRanges": [
      "10.0.0.0/24"
    ],
    "targetTags": [
      "gke-my-first-cluster-1-c86fed8d-node"
    ]
  },
  {
    "allowed": [
      {
        "IPProtocol": "tcp",
        "ports": [
          "22"
        ]
      }
    ],
    "creationTimestamp": "2023-05-12T02:42:40.716-07:00",
    "description": "",
    "direction": "INGRESS",
    "disabled": false,
    "id": "5104281670487618815",
    "kind": "compute#firewall",
    "logConfig": {
      "enable": false
    },
    "name": "gkenetwork1-allow-custom",
    "network": "https://www.googleapis.com/compute/v1/projects/cfos-384323/global/networks/gkenetwork1",
    "priority": 65534,
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
[[ $defaultClustername == "" ]] && defaultClustername="my-first-cluster-1"
[[ $networkName == "" ]] && networkName="gkenetwork"
[[ $subnetName == "" ]] && subnetName="gkenode"

gkeClusterName=$defaultClustername
gkeNetworkName=$(gcloud compute networks list --format="value(name)" --filter="name="$networkName""  --limit=1)
gkeSubnetworkName=$(gcloud compute networks subnets  list --format="value(name)" --filter="name="$subnetName"" --limit=1)

projectName=$(gcloud config list --format="value(core.project)") && \
region=$(gcloud compute networks subnets list --format="value(region)" --limit=1) && \

gcloud services enable container.googleapis.com  && \

gcloud beta container clusters create $gkeClusterName  \
	--no-enable-basic-auth \
	--cluster-version "1.26.3-gke.1000" \
	--release-channel "rapid" \
	--machine-type "g1-small" \
	--image-type "UBUNTU_CONTAINERD" \
	--disk-type "pd-balanced" \
	--disk-size "32" \
	--metadata disable-legacy-endpoints=true \
	--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
	--max-pods-per-node "110" \
	--num-nodes "1" \
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
gke-my-first-cluster-1-default-pool-c25d14b8-4061   Ready    <none>   8m    v1.26.3-gke.1000   10.0.0.3      35.233.153.196   Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
```
- enable worker node ipforwarding 

by default, the GKE come with ipforwarding disabled. for cFOS to work. we have to enable ip forwarding on worker node.
to enable ipforwarding, we need to config *canIpForward: true* for instance profile, for more detail , check  https://cloud.google.com/vpc/docs/using-routes#canipforward.

- paste below command to enable ipforwarding 
```
[[ $defaultClustername == "" ]] && defaultClustername="my-first-cluster-1"
gkeClusterName=$defaultClustername
clustersearchstring=$(gcloud container clusters list --filter=name=$gkeClusterName --format="value(name)" --limit=1)
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1)
projectName=$(gcloud config list --format="value(core.project)")
zone=$(gcloud config list --format="value(compute.zone)" --limit=1)
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
echo "done"
```
- install multus cni 

We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, we need to use filename that alphabetally less than 10 to take priority. here we use *07-multus.conf* which will become the default cni. inside *07-multus.conf* config. we added two specific route which ask POD CIDR subnet and CLUSTER VIP subnet continue to use cluster default network instead of send traffic to cFOS with bridge CNI. 
we also need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission

- paste below command to install multus CNI with manual config 
```
file="multus.yml"
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
                    "dst": "0.0.0.0/0",
                    "dst": "10.140.0.0/14",
                    "dst": "10.144.0.0/20"
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
        - "--multus-conf-file=/tmp/multus-conf/07-multus.conf"
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
```
daemon set "kube-multus-ds" successfully rolled out
```
- you can also ssh into worker node to check more detail
- paste below command to check more detail on workder node  
```
clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) && \
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1) && \
gcloud compute ssh $name --command='sudo cat /etc/cni/net.d/07-multus.conf' && \
gcloud compute ssh $name --command='journalctl -n 10 -u kubelet'
```
- install multus cni 
We will create net-attach-def with bridge CNI ,multus CNI will use this net-attach-def to create bridge network and attach POD to the network.
We use host-local as IPAM CNI.

- paste below command to create net-attach-def
```
file="nad.yml"
cat << EOF > $file 
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: cfosdefaultcni5
spec:
  config: |-
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
              { "dst": "1.2.3.4/32", "gw": "10.1.200.1" }
          ],
          "ranges": [
              [{ "subnet": "10.1.200.0/24" }]
          ]
      }
    }
EOF
kubectl create -f $file && kubectl get net-attach-def

```
- check the result
`kubectl get net-attach-def`
```
NAME              AGE
cfosdefaultcni5   6m41s
```
- create demo application deployment

we use annotation *k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'* to config to POD to use default route point to CFOS.

the pod shall have an additional interface attached to bridge network created by nad and POD 's default route shall point to cFOS.

- paste below command to create application deployment
```
file="app.yml"
cat << EOF > $file 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 1
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'
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
multitool01-deployment-56455644f9-78j26   1/1     Running   0          6m39s
```
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=multitool01 --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/$podName -- ip route && kubectl exec -t po/$podName -- ip address
`
```
default via 10.1.200.252 dev net1 
1.2.3.4 via 10.1.200.1 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.2 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10 
10.140.0.1 dev eth0 scope link src 10.140.0.10 
10.144.0.0/20 via 10.140.0.1 dev eth0 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether 3a:9c:65:f5:9c:12 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.10/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether b2:55:b6:96:67:3d brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.2/24 brd 10.1.200.255 scope global net1
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
read-configmaps   ClusterRole/configmap-reader   6m33s
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: "2023-05-12T09:49:54Z"
  name: read-secrets
  namespace: default
  resourceVersion: "2121"
  uid: 7162420e-e771-4e92-a0ac-32aedc0b1f93
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
cFOS will use annotation to attach to CRD.
k8s.v1.cni.cncf.io/networks means secondary network.
Default interface inside cFOS is net1.
cFOS will have fixed IP 10.1.200.252/32 which is the range of CRD cni configuration.
cFOS can also have a fixed mac address.
Linux capabilities like NET_ADMIN, SYS_AMDIN, NET_RAW are required for ping, sniff and syslog.
cFOS image will be pulled from Docker Hub with pull secret.
the cFOS in GKE by default will not have a default route , We will use cFOS static route to add an default route

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
fos-deployment-9cwb9   1/1     Running   0          5m45s
```
check routing table and ip address
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/$podName -- ip route  && kubectl exec -t po/$podName -- ip address
`
```
1.2.3.4 via 10.1.200.1 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.12 
10.140.0.1 dev eth0 scope link src 10.140.0.12 
10.144.0.0/20 via 10.140.0.1 dev eth0 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc noqueue state UP group default 
    link/ether e6:88:4a:e6:15:57 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.140.0.12/24 brd 10.140.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: net1@if18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
```
check cfos license
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl logs po/$podName
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-12_09:50:48.38540 ok: run: /run/fcn_service/certd: (pid 260) 0s, normally down
2023-05-12_09:50:53.47282 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47291 INFO: 2023/05/12 09:50:53 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-12_09:50:53.47294 INFO: 2023/05/12 09:50:53 got a fos license
2023-05-12_09:50:53.47329 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47334 INFO: 2023/05/12 09:50:53 configmap name: foscfgstaticroute, labels: map[app:fos category:config]
2023-05-12_09:50:53.47336 INFO: 2023/05/12 09:50:53 got a fos config
2023-05-12_09:50:53.47339 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47343 INFO: 2023/05/12 09:50:53 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-12_09:50:53.47345 INFO: 2023/05/12 09:50:53 got a fos config
```
- create configmap for cfos to get configuration 
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS

- paste below command to create configmap that include firewall policy configuration
```
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
           edit "3"
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
           edit "3"
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
  creationTimestamp: "2023-05-12T09:50:10Z"
  labels:
    app: fos
    category: config
  name: foscfgfirewallpolicy
  namespace: default
  resourceVersion: "2325"
  uid: 0c8d8033-5822-4fd7-8939-963d3902672c
```
check cfos log for retrive config from configmap
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl logs po/$podName
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-12_09:50:48.38540 ok: run: /run/fcn_service/certd: (pid 260) 0s, normally down
2023-05-12_09:50:53.47282 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47291 INFO: 2023/05/12 09:50:53 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-12_09:50:53.47294 INFO: 2023/05/12 09:50:53 got a fos license
2023-05-12_09:50:53.47329 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47334 INFO: 2023/05/12 09:50:53 configmap name: foscfgstaticroute, labels: map[app:fos category:config]
2023-05-12_09:50:53.47336 INFO: 2023/05/12 09:50:53 got a fos config
2023-05-12_09:50:53.47339 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47343 INFO: 2023/05/12 09:50:53 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-12_09:50:53.47345 INFO: 2023/05/12 09:50:53 got a fos config
```
- create configmap for cfos to config static route 
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS for static route
the static route created by cFOS by default is in route table 231. 


- paste below command to create configmap that include static route 
```
file="configmapstaticroute.yml"
cat << EOF > $file
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgstaticroute
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config router static
      edit "1"
          set dst 0.0.0.0/0
          set gateway 10.140.0.1
          set device "eth0"
      next
    end
EOF
kubectl create -f $file 
```
- check the result
`
kubectl get configmap foscfgstaticroute -o yaml
`
```
apiVersion: v1
data:
  config: |-
    config router static
      edit "1"
          set dst 0.0.0.0/0
          set gateway 10.140.0.1
          set device "eth0"
      next
    end
  type: partial
kind: ConfigMap
metadata:
  creationTimestamp: "2023-05-12T09:50:11Z"
  labels:
    app: fos
    category: config
  name: foscfgstaticroute
  namespace: default
  resourceVersion: "2342"
  uid: 55c4551a-0274-4ffc-ad25-53eb72d71fd0
```
check cfos log for retrive config from configmap
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl logs po/$podName
`
```

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
Starting services...
System is ready.

2023-05-12_09:50:48.38540 ok: run: /run/fcn_service/certd: (pid 260) 0s, normally down
2023-05-12_09:50:53.47282 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47291 INFO: 2023/05/12 09:50:53 configmap name: fos-license, labels: map[app:fos category:license]
2023-05-12_09:50:53.47294 INFO: 2023/05/12 09:50:53 got a fos license
2023-05-12_09:50:53.47329 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47334 INFO: 2023/05/12 09:50:53 configmap name: foscfgstaticroute, labels: map[app:fos category:config]
2023-05-12_09:50:53.47336 INFO: 2023/05/12 09:50:53 got a fos config
2023-05-12_09:50:53.47339 INFO: 2023/05/12 09:50:53 received a new fos configmap
2023-05-12_09:50:53.47343 INFO: 2023/05/12 09:50:53 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-05-12_09:50:53.47345 INFO: 2023/05/12 09:50:53 got a fos config
```
check cfos static routing table
check routing table and ip address
`
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/$podName -- ip route show table 231
`
```
default via 10.140.0.1 dev eth0 metric 10 
1.2.3.4 via 10.1.200.1 dev net1 
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252 
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.12 
10.140.0.1 dev eth0 scope link src 10.140.0.12 
10.144.0.0/20 via 10.140.0.1 dev eth0 
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
nodeName=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=$(kubectl get pods -l app=fos --field-selector spec.nodeName="$nodeName" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/$podName -- iptables -L -t nat --verbose | grep MASQ 
`
```
   58  4652 MASQUERADE  all  --  any    eth0    anywhere             anywhere            
```
- do a ips test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.

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
date=2023-05-12 time=09:55:45 eventtime=1683885345 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=2 srcip=10.1.200.1 srcport=44324 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
- do a ips test on a target website
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the IPS signature. if match the signature. cFOS can either block it or pass it with alert depends on the policy configured.

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.

- paste below command to send malicous traffic from application pod 
```
url="www.hackthebox.eu"
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- dig $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c 5  $url ; done && \
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://$url ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
```
- check the result
`
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
`
```
date=2023-05-12 time=09:55:31 eventtime=1683885331 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.1 dstip=104.18.9.132 srcintf="net1" dstintf="eth0" sessionid=3 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=57868 dstport=443 hostname="www.hackthebox.eu" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=56623105 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
