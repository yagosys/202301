- preparation
- create a project
- config glcoud environement

```

project="cfos-384323"
region="us-west1"
zone="us-west1-a"
gcloud config set project $project
gcloud config set compute/region $region
gcloud config set compute/zone $zone
gcloud config list

   
```

- create gke cluster

*we are using --enable-ip-alias, so the POD will share VPC ip address space*


```
gkeClusterName="my-first-cluster-1"
gkeNetworkName=$(gcloud compute networks list --format="value(name)" --limit=1)
gkeSubnetworkName=$(gcloud compute networks subnets  list --format="value(name)" --limit=1)

projectName=$(gcloud config list --format="value(core.project)")
region=$(gcloud compute networks subnets list --format="value(region)" --limit=1)

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
echo cluster has podIpv4CidrBlock $(gcloud container clusters describe my-first-cluster-1 --format="value(nodePools.networkConfig.podIpv4CidrBlock)")
echo cluster has servicesIpv4Cidr $(gcloud container clusters describe my-first-cluster-1 --format="value(servicesIpv4Cidr)")


clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1)
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1)
echo cluster worker node vm has internal ip $(gcloud compute instances describe $name --format="value(networkInterfaces.aliasIpRanges)" --format="value(networkInterfaces.networkIP)")
echo cluster worker node vm has alias ip $(gcloud compute instances describe $name  --format="value(networkInterfaces.aliasIpRanges)")


``` 

you shall expected to see below output
```
Note: Modifications on the boot disks of node VMs do not persist across node recreations. Nodes are recreated during manual-upgrade, auto-upgrade, auto-repair, and auto-scaling. To preserve modifications across node recreation, use a DaemonSet.
Default change: During creation of nodepools or autoscaling configuration changes for cluster versions greater than 1.24.1-gke.800 a default location policy is applied. For Spot and PVM it defaults to ANY, and for all other VM kinds a BALANCED policy is used. To change the default values use the `--location-policy` flag.
Note: The Pod address range limits the maximum size of the cluster. Please refer to https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr to learn how to optimize IP address allocation.
Creating cluster my-first-cluster-1 in us-west1-a... Cluster is being health-checked (master is healthy)...done.     
Created [https://container.googleapis.com/v1beta1/projects/cfos-384323/zones/us-west1-a/clusters/my-first-cluster-1].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-west1-a/my-first-cluster-1?project=cfos-384323
kubeconfig entry generated for my-first-cluster-1.
NAME: my-first-cluster-1
LOCATION: us-west1-a
MASTER_VERSION: 1.26.3-gke.1000
MASTER_IP: 34.82.14.152
MACHINE_TYPE: g1-small
NODE_VERSION: 1.26.3-gke.1000
NUM_NODES: 1
STATUS: RUNNING
done
cluster has podIpv4CidrBlock 10.140.0.0/14
cluster has servicesIpv4Cidr 10.144.0.0/20
cluster worker node vm has internal ip 10.0.0.13
cluster worker node vm has alias ip [{'ipCidrRange': '10.140.0.0/24', 'subnetworkRangeName': 'gke-my-first-cluster-1-pods-e8d6aa00'}]
```


check the gke cluster 
`kubectl get node -o wide`
```
NAME                                                STATUS   ROLES    AGE     VERSION            INTERNAL-IP   EXTERNAL-IP    OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz   Ready    <none>   3m54s   v1.26.3-gke.1000   10.0.0.13     34.127.7.195   Ubuntu 22.04.2 LTS   5.15.0-1028-gke   containerd://1.6.18
```

- enable ip-forwarding for GKE worker node VM 
* reference
 https://cloud.google.com/vpc/docs/using-routes#canipforward

```
clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1)
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


- create multus config file 

*we need install multus cni config file to the worker node. so we can create multus cni config, the cni config need config two static route for podIpv4CidrBlock and servicesIpv4Cidr with nexthop point to POD primary interface, as we are going to install a default route to each POD with nexthop point to cFOS*, we first get the podIpv4Cidrblock and serviceIpv4Cidr and then modify multus yaml file with cni config. 

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

you shall see output 

```
customresourcedefinition.apiextensions.k8s.io/network-attachment-definitions.k8s.cni.cncf.io created
clusterrole.rbac.authorization.k8s.io/multus created
clusterrolebinding.rbac.authorization.k8s.io/multus created
serviceaccount/multus created
configmap/multus-cni-config created
daemonset.apps/kube-multus-ds created
Waiting for daemon set "kube-multus-ds" rollout to finish: 0 of 1 updated pods are available...
daemon set "kube-multus-ds" successfully rolled out
```


- check the installation of multus cni

```
clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) && \
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1) && \
gcloud compute ssh $name --command='sudo cat /etc/cni/net.d/07-multus.conf' && \
gcloud compute ssh $name --command='journalctl -n 10 -u kubelet'

```

you shall see output 

```
Warning: Permanently added 'compute.1543850315789202263' (ECDSA) to the list of known hosts.
##############################################################################
# WARNING: Any changes on the boot disk of the node must be made via
#          DaemonSet in order to preserve them across node (re)creations.
#          Node will be (re)created during manual-upgrade, auto-upgrade,
#          auto-repair or auto-scaling.
#          See https://cloud.google.com/kubernetes-engine/docs/concepts/node-images#modifications
#          for more information.
##############################################################################
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
##############################################################################
# WARNING: Any changes on the boot disk of the node must be made via
#          DaemonSet in order to preserve them across node (re)creations.
#          Node will be (re)created during manual-upgrade, auto-upgrade,
#          auto-repair or auto-scaling.
#          See https://cloud.google.com/kubernetes-engine/docs/concepts/node-images#modifications
#          for more information.
##############################################################################
May 02 08:55:55 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:55:55.750876    2264 provider.go:102] Refreshing cache for provider: *gcp.DockerConfigURLKeyProvider
May 02 08:55:55 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:55:55.751913    2264 credentialutil.go:63] "Failed to read URL" statusCode=404 URL="http://metadata.google.internal./computeMetadata/v1/instance/attributes/google-dockercfg-url"
May 02 08:55:55 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: E0502 08:55:55.752087    2264 gcpcredential.go:74] while reading 'google-dockercfg-url' metadata: http status code: 404 while fetching url http://metadata.google.internal./computeMetadata/v1/instance/attributes/google-dockercfg-url
May 02 08:55:56 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:55:56.177637    2264 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="kube-system/kube-multus-ds-kk2r8" event=&{ID:7eaba53e-63d2-4906-9a16-ff315c3337fd Type:ContainerStarted Data:d08bfba7963c51291ff456fc9639ab91efe1ee5c716137335895e9744eb746ff}
May 02 08:56:06 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:06.223307    2264 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="kube-system/kube-multus-ds-kk2r8" event=&{ID:7eaba53e-63d2-4906-9a16-ff315c3337fd Type:ContainerStarted Data:7baae34a275025ee9803614c912ba1916f452fcd6569e835e556566e79a52357}
May 02 08:56:09 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:09.232422    2264 generic.go:332] "Generic (PLEG): container finished" podID=7eaba53e-63d2-4906-9a16-ff315c3337fd containerID="7baae34a275025ee9803614c912ba1916f452fcd6569e835e556566e79a52357" exitCode=0
May 02 08:56:09 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:09.232489    2264 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="kube-system/kube-multus-ds-kk2r8" event=&{ID:7eaba53e-63d2-4906-9a16-ff315c3337fd Type:ContainerDied Data:7baae34a275025ee9803614c912ba1916f452fcd6569e835e556566e79a52357}
May 02 08:56:10 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:10.240813    2264 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="kube-system/kube-multus-ds-kk2r8" event=&{ID:7eaba53e-63d2-4906-9a16-ff315c3337fd Type:ContainerStarted Data:554141b1bc0a0747986f75b7f6f0207d9e525553c74bd98b11a4154f780bffa1}
May 02 08:56:10 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:10.265242    2264 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="kube-system/kube-multus-ds-kk2r8" podStartSLOduration=-9.223372021589586e+09 pod.CreationTimestamp="2023-05-02 08:55:55 +0000 UTC" firstStartedPulling="2023-05-02 08:55:55.732815628 +0000 UTC m=+520.894080809" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2023-05-02 08:56:10.264334729 +0000 UTC m=+535.425599933" watchObservedRunningTime="2023-05-02 08:56:10.265190328 +0000 UTC m=+535.426455533"
May 02 08:56:15 gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz kubelet[2264]: I0502 08:56:15.430592    2264 kubelet_getters.go:182] "Pod status updated" pod="kube-system/kube-proxy-gke-my-first-cluster-1-default-pool-c0a2ad16-0bvz" status=Running

```

- create net-attach-def

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
you shall see output 

```
networkattachmentdefinition.k8s.cni.cncf.io/cfosdefaultcni5 created
NAME              AGE
cfosdefaultcni5   0s
```


- create application deployment.

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

you shall see output 
```
deployment.apps/multitool01-deployment created
Waiting for deployment "multitool01-deployment" rollout to finish: 0 of 1 updated replicas are available...
deployment "multitool01-deployment" successfully rolled out
```


- apply docker pull secret and cfos license 


```
file="$HOME/license/dockerinterbeing.yaml"
[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"
file="$HOME/license/fos_license.yaml"
[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"
```
you shall see output
```
secret/dockerinterbeing created
configmap/fos-license created
```


- create cfos account
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

you shall see output

```
clusterrole.rbac.authorization.k8s.io/configmap-reader created
rolebinding.rbac.authorization.k8s.io/read-configmaps created
clusterrole.rbac.authorization.k8s.io/secrets-reader created
rolebinding.rbac.authorization.k8s.io/read-secrets created
```

- create cfos daemonSet

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

you shall see output

```
service/fos-deployment created
daemonset.apps/fos-deployment created
Waiting for daemon set "fos-deployment" rollout to finish: 0 of 1 updated pods are available...
daemon set "fos-deployment" successfully rolled out
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-nb69v   1/1     Running   0          9s
```




- config firewall policy
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

you shall see output

```
configmap/foscfgfirewallpolicy created
```


- config cfos static route
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

you shall see output 

```
configmap/foscfgstaticroute created
```

- restart cfos daemonSet 

```
kubectl rollout status ds/fos-deployment && \
kubectl rollout restart ds/fos-deployment && \
kubectl rollout status ds/fos-deployment && \
podname=$(kubectl get pod -l app=fos  | grep Running | grep fos | cut -d " " -f 1) && \
echo 'check cfos iptables for snat entry' && \
kubectl exec -it po/$podname -- iptables -L -t nat --verbose | grep MASQ && \
echo 'done'
```

you shall see output

```
daemon set "fos-deployment" successfully rolled out
daemonset.apps/fos-deployment restarted
Waiting for daemon set "fos-deployment" rollout to finish: 0 out of 1 new pods have been updated...
Waiting for daemon set "fos-deployment" rollout to finish: 0 out of 1 new pods have been updated...
Waiting for daemon set "fos-deployment" rollout to finish: 0 out of 1 new pods have been updated...
Waiting for daemon set "fos-deployment" rollout to finish: 0 of 1 updated pods are available...
daemon set "fos-deployment" successfully rolled out
check cfos iptables for snat entry
   26  2188 MASQUERADE  all  --  any    eth0    anywhere             anywhere
done
```


- check routing table on application pod 
```
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ kubectl get pod | grep multi | awk '{print $1}' |  while read line;  do kubectl exec -t po/$line -- ip r show ; done
default via 10.1.200.252 dev net1
1.2.3.4 via 10.1.200.1 dev net1
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.2
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10
10.140.0.1 dev eth0 scope link src 10.140.0.10
10.144.0.0/20 via 10.140.0.1 dev eth0
```

- check routing table on cfos 


```
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ kubectl get pod | grep fos | awk '{print $1}' |  while read line;  do kubectl exec -t po/$line -- ip r show table 231 ; done
default via 10.140.0.1 dev eth0 metric 10
1.2.3.4 via 10.1.200.1 dev net1
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.12
10.140.0.1 dev eth0 scope link src 10.140.0.12
10.144.0.0/20 via 10.140.0.1 dev eth0
```

-  send ips attack traffic

```
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://www.eicar.org  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/ips.0  ; done
```
 
you shall see output 

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0
curl: (28) Operation timed out after 5000 milliseconds with 0 bytes received
command terminated with exit code 28
date=2023-05-02 time=09:01:37 eventtime=1683018097 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.200.1 dstip=89.238.73.97 srcintf="net1" dstintf="eth0" sessionid=2 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=59064 dstport=443 hostname="www.eicar.org" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=218103809 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```

 
- access malicous website

```
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.eicar.org/download/eicar.com.txt  ; done
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
```

you shall see output
```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 403 Forbidden
  0  5211    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: frame-ancestors 'self'
Content-Type: text/html; charset="utf-8"
Content-Length: 5211
Connection: Close

date=2023-05-02 time=09:02:02 eventtime=1683018122 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=4 srcip=10.1.200.1 srcport=46300 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```

- clean up 

```
name=$(gcloud container clusters list --format="value(name)" --limit=1) &&  \
projectName=$(gcloud config list --format="value(core.project)") && \
zone=$(gcloud config list --format="value(compute.zone)" --limit=1) && \
gcloud container clusters delete $name
```




