- ## install eks cluster 

```
cat << EOF | eksctl create cluster -f 

ADFS-Admin:~/EKSDemo (main) $ cat EKSDemoConfig.yaml 
apiVersion: eksctl.io/v1alpha5
availabilityZones:
- ap-east-1b
- ap-east-1a
cloudWatch:
  clusterLogging: {}
iam:
  vpcResourceControllerPolicy: true
  withOIDC: false
kind: ClusterConfig
kubernetesNetworkConfig:
  ipFamily: IPv4
  serviceIPv4CIDR: 10.96.0.0/12
managedNodeGroups:
- amiFamily: Ubuntu2004
  desiredCapacity: 1
  disableIMDSv1: false
  disablePodIMDS: false
  iam:
    withAddonPolicies:
      albIngress: false
      appMesh: false
      appMeshPreview: false
      autoScaler: false
      awsLoadBalancerController: false
      certManager: false
      cloudWatch: false
      ebs: false
      efs: false
      externalDNS: false
      fsx: false
      imageBuilder: false
      xRay: false
  instanceSelector: {}
  instanceTypes:
  - t3.small
  labels:
    alpha.eksctl.io/cluster-name: EKSDemo
    alpha.eksctl.io/nodegroup-name: DemoNodeGroup
  maxSize: 1
  minSize: 1
  name: DemoNodeGroup
  privateNetworking: false
  releaseVersion: ""
  securityGroups:
    withLocal: null
    withShared: null
  ssh:
    allow: true
    publicKeyPath: /home/ec2-user/.ssh/id_rsa.pub
  tags:
    alpha.eksctl.io/nodegroup-name: DemoNodeGroup
    alpha.eksctl.io/nodegroup-type: managed
  volumeIOPS: 3000
  volumeSize: 80
  volumeThroughput: 125
  volumeType: gp3
metadata:
  name: EKSDemo
  region: ap-east-1
  version: "1.25"
privateCluster:
  enabled: false
  skipEndpointCreation: false
vpc:
  autoAllocateIPv6: false
  cidr: 10.0.0.0/16
  clusterEndpoints:
    privateAccess: false
    publicAccess: true
  manageSharedNodeSecurityGroupRules: true
  nat:
    gateway: Single

EOF 

```

you shall able to get a cluster


```
ADFS-Admin:~/EKSDemo (main) $ eksctl create cluster -f EKSDemoConfig.yaml
2023-03-19 01:01:12 [ℹ]  eksctl version 0.133.0
2023-03-19 01:01:12 [ℹ]  using region ap-east-1
2023-03-19 01:01:12 [ℹ]  subnets for ap-east-1b - public:10.0.0.0/19 private:10.0.64.0/19
2023-03-19 01:01:12 [ℹ]  subnets for ap-east-1a - public:10.0.32.0/19 private:10.0.96.0/19
2023-03-19 01:01:12 [ℹ]  nodegroup "DemoNodeGroup" will use "ami-028a68d319d88fe0c" [Ubuntu2004/1.25]
2023-03-19 01:01:12 [ℹ]  using SSH public key "/home/ec2-user/.ssh/id_rsa.pub" as "eksctl-EKSDemo-nodegroup-DemoNodeGroup-d9:13:25:30:68:71:06:75:d6:1c:68:4f:88:24:ab:4a" 
2023-03-19 01:01:12 [ℹ]  using Kubernetes version 1.25
2023-03-19 01:01:12 [ℹ]  creating EKS cluster "EKSDemo" in "ap-east-1" region with managed nodes
2023-03-19 01:01:12 [ℹ]  1 nodegroup (DemoNodeGroup) was included (based on the include/exclude rules)
2023-03-19 01:01:12 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-03-19 01:01:12 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-03-19 01:01:12 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-east-1 --cluster=EKSDemo'
2023-03-19 01:01:12 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "EKSDemo" in "ap-east-1"
2023-03-19 01:01:12 [ℹ]  CloudWatch logging will not be enabled for cluster "EKSDemo" in "ap-east-1"
2023-03-19 01:01:12 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-east-1 --cluster=EKSDemo'
2023-03-19 01:01:12 [ℹ]  
2 sequential tasks: { create cluster control plane "EKSDemo", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "DemoNodeGroup",
    } 
}
2023-03-19 01:01:12 [ℹ]  building cluster stack "eksctl-EKSDemo-cluster"
2023-03-19 01:01:13 [ℹ]  deploying stack "eksctl-EKSDemo-cluster"
2023-03-19 01:01:43 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:02:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:03:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:04:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:05:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:06:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:07:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:08:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:09:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:10:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:11:13 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-19 01:13:14 [ℹ]  building managed nodegroup stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:13:14 [ℹ]  deploying stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:13:14 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:13:44 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:14:24 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:15:44 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:17:10 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-19 01:17:10 [ℹ]  waiting for the control plane to become ready
2023-03-19 01:17:11 [✔]  saved kubeconfig as "/home/ec2-user/.kube/config"
2023-03-19 01:17:11 [ℹ]  no tasks
2023-03-19 01:17:11 [✔]  all EKS cluster resources for "EKSDemo" have been created
2023-03-19 01:17:11 [ℹ]  nodegroup "DemoNodeGroup" has 1 node(s)
2023-03-19 01:17:11 [ℹ]  node "ip-10-0-20-197.ap-east-1.compute.internal" is ready
2023-03-19 01:17:11 [ℹ]  waiting for at least 1 node(s) to become ready in "DemoNodeGroup"
2023-03-19 01:17:11 [ℹ]  nodegroup "DemoNodeGroup" has 1 node(s)
2023-03-19 01:17:11 [ℹ]  node "ip-10-0-20-197.ap-east-1.compute.internal" is ready
2023-03-19 01:17:12 [ℹ]  kubectl command should work with "/home/ec2-user/.kube/config", try 'kubectl get nodes'
2023-03-19 01:17:12 [✔]  EKS cluster "EKSDemo" in "ap-east-1" region is ready
ADFS-Admin:~/EKSDemo (main) $ 
```
- ## install multus

git clone multus then install 

```
kubectl create -f multus-daemonset.yml 
customresourcedefinition.apiextensions.k8s.io/network-attachment-definitions.k8s.cni.cncf.io created
clusterrole.rbac.authorization.k8s.io/multus created
clusterrolebinding.rbac.authorization.k8s.io/multus created
serviceaccount/multus created
configmap/multus-cni-config created
daemonset.apps/kube-multus-ds created
```
- ## create net-attach-def 

```
cat << EOF | kubectl apply -f -

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
              { "dst": "10.96.0.0/12","gw": "10.0.200.1" },
              { "dst": "10.0.0.2/32", "gw": "10.0.200.1" }
          ],
          "ranges": [
              [{ "subnet": "10.0.200.0/24" }]
          ]
      }
    }
EOF 

networkattachmentdefinition.k8s.cni.cncf.io/cfosdefaultcni5 created

```
- ## deploy cfos daemonset 

- ### install dockersecret and cfos license

```
ADFS-Admin:~ $ kubectl create -f dockersecret.yaml 
secret/dockerinterbeing created
ADFS-Admin:~ $ kubectl create -f fos_license.yaml 
configmap/fos-license created
```
- ### install cfos from yaml file
```
cat << | kubectl apply -f - 
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

---
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
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.0.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
        #k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5" } ] ' 
    spec:
      containers:
      - name: fos
        image: interbeing/fos:v7231x86

        securityContext:
          capabilities:
              add: ["NET_ADMIN","SYS_ADMIN","NET_RAW"]
          privileged: true
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
          path: /cfosdata
          type: DirectoryOrCreate


EOF

```
- ### check result 
```
ADFS-Admin:~/environment $ kubectl create -f cfos_ds_deployment.yaml 
clusterrole.rbac.authorization.k8s.io/configmap-reader created
rolebinding.rbac.authorization.k8s.io/read-configmaps created
clusterrole.rbac.authorization.k8s.io/secrets-reader created
rolebinding.rbac.authorization.k8s.io/read-secrets created
configmap/foscfgfirewallpolicy created
service/fos-deployment created
daemonset.apps/fos-deployment created

ADFS-Admin:~/environment $ kubectl get pod
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-9ffwt   1/1     Running   0          88s
ADFS-Admin:~/environment $ kubectl exec -it po/fos-deployment-9ffwt -- sh
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default 
    link/ether 82:4c:40:65:df:a5 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.18.63/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::804c:40ff:fe65:dfa5/64 scope link 
       valid_lft forever preferred_lft forever
5: net1@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether c2:a2:44:6f:bd:8e brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.200.252/24 brd 10.0.200.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::c0a2:44ff:fe6f:bd8e/64 scope link 
       valid_lft forever preferred_lft forever
# 
```


- ### deployment application 

```
cat << EOF | kubectl apply -f - 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 2
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.0.200.252"]  } ]'
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
```

- ###  show result

```
ADFS-Admin:~/environment $ kubectl get pod
NAME                                      READY   STATUS    RESTARTS   AGE
fos-deployment-9ffwt                      1/1     Running   0          5m23s
multitool01-deployment-779b44cdc4-6m7f7   1/1     Running   0          68s
multitool01-deployment-779b44cdc4-h5j7k   1/1     Running   0          68s
ADFS-Admin:~/environment $ kubectl exec -it po/multitool01-deployment-779b44cdc4-6m7f7 -- sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default 
    link/ether ba:20:3c:f8:e2:2f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.15.6/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::b820:3cff:fef8:e22f/64 scope link 
       valid_lft forever preferred_lft forever
5: net1@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 4e:95:73:59:01:c4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.200.254/24 brd 10.0.200.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::4c95:73ff:fe59:1c4/64 scope link 
       valid_lft forever preferred_lft forever
/ # ip r
default via 10.0.200.252 dev net1 
10.0.0.2 via 10.0.200.1 dev net1 
10.0.200.0/24 dev net1 proto kernel scope link src 10.0.200.254 
10.96.0.0/12 via 10.0.200.1 dev net1 
169.254.1.1 dev eth0 scope link 
/ # ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.64 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=51 time=0.867 ms
^C
--- 1.1.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.867/1.251/1.635/0.384 ms
/ # curl -k https://ipinfo.io
{
  "ip": "16.162.119.78",
  "hostname": "ec2-16-162-119-78.ap-east-1.compute.amazonaws.com",
  "city": "Hong Kong",
  "region": "Central and Western",
  "country": "HK",
  "loc": "22.2783,114.1747",
  "org": "AS16509 Amazon.com, Inc.",
  "timezone": "Asia/Hong_Kong",
  "readme": "https://ipinfo.io/missingauth"
}/ # 

```
