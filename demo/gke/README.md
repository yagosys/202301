- preparation
- create a project
- config glcoud environement
```
   gcloud config set project cfos-384323
   gcloud config set compute/region us-west1
   gcloud config set compute/zone us-west1-a

   
```

- create gke cluster

*we are using --enable-ip-alias, so the POD will share VPC ip address space*


```
gkeClusterName="$1"
gkeNetworkName="$2"
gkeSubnetworkName="$3"

[[ "$1" == "" ]] && gkeClusterName="my-first-cluster-1"
[[ "$2" == "" ]] && gkeNetworkName=$(gcloud compute networks list --format="value(name)" --limit=1)
[[ "$3" == "" ]] && gkeSubnetworkName=$(gcloud compute networks subnets  list --format="value(name)" --limit=1)

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

``` 



check the gke cluster 
`kubectl get node`
```
NAME                                                STATUS   ROLES    AGE     VERSION
gke-my-first-cluster-1-default-pool-f1f19bf3-x57f   Ready    <none>   2m12s   v1.26.3-gke.1000
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
    --zone us-west1-a \
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

-- create multus config file 

*we need install multus cni config file to the worker node. so we can create multus cni config, the cni config need config two static route for podIpv4CidrBlock and servicesIpv4Cidr with nexthop point to POD primary interface, as we are going to install a default route to each POD with nexthop point to cFOS*, we first get the podIpv4Cidrblock and serviceIpv4Cidr and then modify multus yaml file with cni config. 

- get the cluster services-ipv4-cidr and cluster-ipv4-cidr

```
gcloud container clusters describe my-first-cluster-1 --format="value(nodePools.networkConfig.podIpv4CidrBlock)"
gcloud container clusters describe my-first-cluster-1 --format="value(servicesIpv4Cidr)"
```
you may see output like

```
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ gcloud container clusters describe my-first-cluster-1 --format="value(nodePools.networkConfig.podIpv4CidrBlock)"
10.140.0.0/14
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ gcloud container clusters describe my-first-cluster-1 --format="value(servicesIpv4Cidr)"
10.144.0.0/20
```
- create multus cni config file with above service and pod ipv4 cidr

```
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

```
* we also need change the nae of cni config to 07-multus.conf instead of default 70-multus.conf, as the GKE cluster default cni with name start with "10-". so we change to any name that lower than "10". here we use 07. so this multus CNI will get priority *

*the final multus config will like below*

-- install multus cni 



```
cat  << EOF  | kubect create -f - 

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
                    "dst": "10.140.0.0/16"
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

```
- check the installation of multus cni

`kubectl logs ds/kube-multus-ds -n kube-system -c kube-multus` shall give below output which indicate that multus CNI is waiting to be called.
```
2023-04-28T01:35:44+00:00 Entering sleep (success)...
```

-- create nad crd for POD's additional interface

```
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
              { "dst": "1.2.3.4/32","gw": "10.1.200.1" }
          ],
          "ranges": [
              [{ "subnet": "10.1.200.0/24" }]
          ]
      }
    }

```


-- create cfos image pull secret
-- create configmap for cfos license



-- create cfos account
-- create cfos


-- config cfos static route
```

config router static
    edit "1"
        set gateway 10.140.0.1
        set device "eth0"
    next
end
```

--- config firewall policy
```
config firewall policy
    edit "3"
        set utm-status enable
        set name "pod_to_internet_HTTPS_HTTP"
        set srcintf any
        set dstintf eth0
        set srcaddr all
        set dstaddr all
        set service ALL
        set ssl-ssh-profile "deep-inspection"
        set webfilter-profile "default"
        set ips-sensor "default"
        set nat enable
    next
end
```

---

```
kubectl create -f cfosfirewallpolicy.yaml && \
kubectl create -f cfosstaticroute.yaml && \
sleep 5 && \
kubectl rollout restart ds/fos-deployment && \
kubectl rollout status ds/fos-deployment
```


-- create application pod

-- check routing table on application pod 
```
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ kubectl get pod | grep multi | awk '{print $1}' |  while read line;  do kubectl exec -t po/$line -- ip r show ; done
default via 10.1.200.252 dev net1
1.2.3.4 via 10.1.200.1 dev net1
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.2
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.10
10.140.0.1 dev eth0 scope link src 10.140.0.10
10.144.0.0/20 via 10.140.0.1 dev eth0
```

--- check routing table on cfos 


```
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ kubectl get pod | grep fos | awk '{print $1}' |  while read line;  do kubectl exec -t po/$line -- ip r show table 231 ; done
default via 10.140.0.1 dev eth0 metric 10
1.2.3.4 via 10.1.200.1 dev net1
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252
10.140.0.0/24 via 10.140.0.1 dev eth0 src 10.140.0.12
10.140.0.1 dev eth0 scope link src 10.140.0.12
10.144.0.0/20 via 10.140.0.1 dev eth0
```

--- send test traffic

```
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
wandy@cloudshell:~/github/cFOSonGKE (cfos-384323)$ ./webftest.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
HTTP/1.1 403 Forbidden  0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0  5211    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: frame-ancestors 'self'
Content-Type: text/html; charset="utf-8"
Content-Length: 5211
Connection: Close

date=2023-05-02 time=01:49:49 eventtime=1682992189 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=10 srcip=10.1.200.1 srcport=41646 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-02 time=01:51:27 eventtime=1682992287 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=12 srcip=10.1.200.1 srcport=58368 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-05-02 time=01:53:25 eventtime=1682992405 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=16 srcip=10.1.200.1 srcport=37128 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```
