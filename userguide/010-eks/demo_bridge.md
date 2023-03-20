- ## network diagram

```
 eth0-application pod --net1--10.0.200/24--net1---cfos pod --- eth0 --- internet

```

- ## install tool eksctl
*https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html*

- ### for macos
```
brew upgrade eksctl && { brew link --overwrite eksctl; } || { brew tap weaveworks/tap; brew install weaveworks/tap/eksctl; }

```

- ### for linux
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

```

- ### use eksctl to deploy eks cluster

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
  desiredCapacity: 2
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
  maxSize: 2
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
(base) ➜  eks git:(main) ✗ eksctl create cluster -f EKSDemoConfig.yaml
2023-03-20 15:19:29 [ℹ]  eksctl version 0.134.0
2023-03-20 15:19:29 [ℹ]  using region ap-east-1
2023-03-20 15:19:29 [ℹ]  subnets for ap-east-1b - public:10.0.0.0/19 private:10.0.64.0/19
2023-03-20 15:19:29 [ℹ]  subnets for ap-east-1a - public:10.0.32.0/19 private:10.0.96.0/19
2023-03-20 15:19:29 [ℹ]  nodegroup "DemoNodeGroup" will use "ami-028a68d319d88fe0c" [Ubuntu2004/1.25]
2023-03-20 15:19:30 [ℹ]  using SSH public key "/Users/i/.ssh/id_rsa.pub" as "eksctl-EKSDemo-nodegroup-DemoNodeGroup-51:77:a9:85:2c:84:79:cb:d9:f7:85:34:4c:20:5f:00"
2023-03-20 15:19:30 [ℹ]  using Kubernetes version 1.25
2023-03-20 15:19:30 [ℹ]  creating EKS cluster "EKSDemo" in "ap-east-1" region with managed nodes
2023-03-20 15:19:30 [ℹ]  1 nodegroup (DemoNodeGroup) was included (based on the include/exclude rules)
2023-03-20 15:19:30 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-03-20 15:19:30 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-03-20 15:19:30 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-east-1 --cluster=EKSDemo'
2023-03-20 15:19:30 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "EKSDemo" in "ap-east-1"
2023-03-20 15:19:30 [ℹ]  CloudWatch logging will not be enabled for cluster "EKSDemo" in "ap-east-1"
2023-03-20 15:19:30 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-east-1 --cluster=EKSDemo'
2023-03-20 15:19:30 [ℹ]
2 sequential tasks: { create cluster control plane "EKSDemo",
    2 sequential sub-tasks: {
        wait for control plane to become ready,
        create managed nodegroup "DemoNodeGroup",
    }
}
2023-03-20 15:19:30 [ℹ]  building cluster stack "eksctl-EKSDemo-cluster"
2023-03-20 15:19:30 [ℹ]  deploying stack "eksctl-EKSDemo-cluster"
2023-03-20 15:20:00 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:20:31 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:21:31 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:22:32 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:23:33 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:24:33 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:25:34 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:26:34 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:27:35 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:28:35 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:29:36 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-20 15:31:40 [ℹ]  building managed nodegroup stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:31:41 [ℹ]  deploying stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:31:41 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:32:12 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:33:02 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:34:44 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-20 15:34:44 [ℹ]  waiting for the control plane to become ready
2023-03-20 15:34:44 [✔]  saved kubeconfig as "/Users/i/.kube/config"
2023-03-20 15:34:44 [ℹ]  no tasks
2023-03-20 15:34:44 [✔]  all EKS cluster resources for "EKSDemo" have been created
2023-03-20 15:34:44 [ℹ]  nodegroup "DemoNodeGroup" has 2 node(s)
2023-03-20 15:34:44 [ℹ]  node "ip-10-0-23-106.ap-east-1.compute.internal" is ready
2023-03-20 15:34:44 [ℹ]  node "ip-10-0-56-175.ap-east-1.compute.internal" is ready
2023-03-20 15:34:44 [ℹ]  waiting for at least 1 node(s) to become ready in "DemoNodeGroup"
2023-03-20 15:34:44 [ℹ]  nodegroup "DemoNodeGroup" has 2 node(s)
2023-03-20 15:34:44 [ℹ]  node "ip-10-0-23-106.ap-east-1.compute.internal" is ready
2023-03-20 15:34:44 [ℹ]  node "ip-10-0-56-175.ap-east-1.compute.internal" is ready
2023-03-20 15:34:45 [ℹ]  kubectl command should work with "/Users/i/.kube/config", try 'kubectl get nodes'
2023-03-20 15:34:45 [✔]  EKS cluster "EKSDemo" in "ap-east-1" region is ready
(base) ➜  eks git:(main) ✗
```

- ## check eks deployment

```
(base) ➜  eks git:(main) ✗ kubectl get node -o wide
NAME                                        STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP    OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
ip-10-0-23-106.ap-east-1.compute.internal   Ready    <none>   16m   v1.25.6   10.0.23.106   18.166.66.47   Ubuntu 20.04.6 LTS   5.15.0-1031-aws   containerd://1.6.12
ip-10-0-56-175.ap-east-1.compute.internal   Ready    <none>   16m   v1.25.6   10.0.56.175   18.167.99.60   Ubuntu 20.04.6 LTS   5.15.0-1031-aws   containerd://1.6.12
(base) ➜  eks git:(main) ✗
```
- ## check default aws-cni installation

```
(base) ➜  eks git:(main) ✗ k logs ds/aws-node -n kube-system
Found 2 pods, using pod/aws-node-fcm6h
Defaulted container "aws-node" out of: aws-node, aws-vpc-cni-init (init)
Installed /host/opt/cni/bin/aws-cni
Installed /host/opt/cni/bin/egress-v4-cni
time="2023-03-20T07:33:50Z" level=info msg="Starting IPAM daemon... "
time="2023-03-20T07:33:50Z" level=info msg="Checking for IPAM connectivity... "
time="2023-03-20T07:33:51Z" level=info msg="Copying config file... "
time="2023-03-20T07:33:51Z" level=info msg="Successfully copied CNI plugin binary and config file."
(base) ➜  eks git:(main) ✗
```



- ## install multus into eks cluster

*git clone multus then install*


```
git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni
cat ./deployments/multus-daemonset.yml | kubectl apply -f -
```
- ### check multus deployment
```
(base) ➜  eks git:(main) ✗ k logs ds/kube-multus-ds -n kube-system
Found 2 pods, using pod/kube-multus-ds-2hp94
Defaulted container "kube-multus" out of: kube-multus, install-multus-binary (init)
2023-03-20T07:57:18+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-03-20T07:57:18+00:00 Using MASTER_PLUGIN: 10-aws.conflist
2023-03-20T07:57:20+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-03-20T07:57:20+00:00 Using /host/etc/cni/net.d/10-aws.conflist as a source to generate the Multus configuration
2023-03-20T07:57:20+00:00 Config file created @ /host/etc/cni/net.d/00-multus.conf
{ "cniVersion": "0.3.1", "name": "multus-cni-network", "type": "multus", "capabilities": {"portMappings": true}, "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig", "delegates": [ { "cniVersion": "0.4.0", "name": "aws-cni", "disableCheck": true, "plugins": [ { "name": "aws-cni", "type": "aws-cni", "vethPrefix": "eni", "mtu": "9001", "podSGEnforcingMode": "strict", "pluginLogFile": "/var/log/aws-routed-eni/plugin.log", "pluginLogLevel": "DEBUG" }, { "name": "egress-v4-cni", "type": "egress-v4-cni", "mtu": 9001, "enabled": "false", "randomizeSNAT": "prng", "nodeIP": "10.0.56.175", "ipam": { "type": "host-local", "ranges": [[{"subnet": "169.254.172.0/22"}]], "routes": [{"dst": "0.0.0.0/0"}], "dataDir": "/run/cni/v6pd/egress-v4-ipam" }, "pluginLogFile": "/var/log/aws-routed-eni/egress-v4-plugin.log", "pluginLogLevel": "DEBUG" }, { "type": "portmap", "capabilities": {"portMappings": true}, "snat": true } ] } ] }
2023-03-20T07:57:20+00:00 Entering sleep (success)...
(base) ➜  eks git:(main) ✗

```
- ## create net-attach-def with bridge cni
*this will also install bridge interface on eacho host node with gateway function enabled*


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
              { "dst": "10.0.0.0/16","gw": "10.0.200.1" },
              { "dst": "10.0.0.2/32", "gw": "10.0.200.1" }
          ],
          "ranges": [
              [{ "subnet": "10.0.200.0/24" }]
          ]
      }
    }
EOF

```


- ### install dockersecret and cfos license
*please create your own secret to pull cfos image*
*please create your own cfos license configmap file*

```
ADFS-Admin:~ $ kubectl create -f dockersecret.yaml
secret/dockerinterbeing created
ADFS-Admin:~ $ kubectl create -f fos_license.yaml
configmap/fos-license created
```

- ### create  service accont and clusterRole for cfos  to read configmap

```
cat << EOF | kubectl apply -f -
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

```

- ### create cfos daemonSet

```
cat << EOF | kubectl apply -f -
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
    spec:
      containers:
      - name: fos
        image: interbeing/fos:v7231x86

        securityContext:
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
          path: /cfosdata
          type: DirectoryOrCreate

EOF
```
- ### check cfos up and running

```
(base) ➜  eks git:(main) ✗ k get pod
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-4scpz   1/1     Running   0          23s
fos-deployment-bpb7p   1/1     Running   0          23s
```


- ### create clusterIP for cfos restful service

```
cat << EOF | kubectl apply -f -

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
EOF

```

- ### check cfos boot log for license

```
(base) ➜  eks git:(main) ✗ k logs po/fos-deployment-4scpz

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/03/20 08:06:59 importing license...
INFO: 2023/03/20 08:06:59 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-03-20_08:06:59.78718 ok: run: /run/fcn_service/certd: (pid 274) 0s, normally down
2023-03-20_08:07:04.89770 INFO: 2023/03/20 08:07:04 received a new fos configmap
2023-03-20_08:07:04.89771 INFO: 2023/03/20 08:07:04 configmap name: fos-license, labels: map[app:fos category:license]
2023-03-20_08:07:04.89771 INFO: 2023/03/20 08:07:04 got a fos license
(base) ➜  eks git:(main) ✗
```

- ### exec shell into cfos check iptables
*the **fcn_nat** chain does not have any rule installed. so all packets from POSTROUTING to this chain will be dropped*


```
(base) ➜  eks git:(main) ✗ k exec -it po/fos-deployment-4scpz  -- sh
# iptables -t nat -L --verbose
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 fcn_prenat  all  --  any    any     anywhere             anywhere

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 7 packets, 659 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 7 packets, 659 bytes)
 pkts bytes target     prot opt in     out     source               destination
    7   659 fcn_nat    all  --  any    any     anywhere             anywhere

Chain fcn_nat (1 references)
 pkts bytes target     prot opt in     out     source               destination

Chain fcn_prenat (1 references)
 pkts bytes target     prot opt in     out     source               destination
#
```


- ### create cfos default firewall policy

```
cat << EOF | kubectl apply -f -
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
EOF

```

- ### check the iptables change

*a rule `0     0 MASQUERADE  all  --  any    eth0    anywhere             anywhere` have been installed on fcn_nat chain*

```
# iptables -L -t nat --verbose
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 fcn_prenat  all  --  any    any     anywhere             anywhere

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    7   659 fcn_nat    all  --  any    any     anywhere             anywhere

Chain fcn_nat (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  any    eth0    anywhere             anywhere

Chain fcn_prenat (1 references)
 pkts bytes target     prot opt in     out     source               destination
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
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF

```


- ### check application deployment


```
(base) ➜  eks git:(main) ✗ k get pod
NAME                                      READY   STATUS    RESTARTS   AGE
fos-deployment-4scpz                      1/1     Running   0          10m
fos-deployment-bpb7p                      1/1     Running   0          10m
multitool01-deployment-779b44cdc4-5dphs   1/1     Running   0          11s
multitool01-deployment-779b44cdc4-8bhbf   1/1     Running   0          11s
```

- ### check cfos
*cfos has fixed ip address `10.0.200.252` on net1*
```
(base) ➜  eks git:(main) ✗ k exec -it po/fos-deployment-7z7lq -- sh
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 96:8e:33:f8:01:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.35.90/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::948e:33ff:fef8:104/64 scope link
       valid_lft forever preferred_lft forever
5: net1@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 0a:03:3e:7d:22:47 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.200.252/24 brd 10.0.200.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::803:3eff:fe7d:2247/64 scope link
       valid_lft forever preferred_lft forever
#
```

*cfos routing table*

```
# ip r
default via 169.254.1.1 dev eth0
10.0.0.0/16 via 10.0.200.1 dev net1
10.0.0.2 via 10.0.200.1 dev net1
10.0.200.0/24 dev net1 proto kernel scope link src 10.0.200.252
10.96.0.0/12 via 10.0.200.1 dev net1
169.254.1.1 dev eth0 scope link
#
```

*cfos shall able to reach interface*

```
# ping -c 1 1.1.1.1
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: seq=0 ttl=52 time=1.152 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.152/1.152/1.152 ms
#
```

- ### check cfos application

*app has net1 interface from net-attach-def crd*

```
(base) ➜  eks git:(main) ✗ k exec -it po/multitool01-deployment-779b44cdc4-5dphs  -- sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 2a:e1:a1:76:09:9b brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.58.122/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::28e1:a1ff:fe76:99b/64 scope link
       valid_lft forever preferred_lft forever
5: net1@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether de:ba:57:c0:1e:0e brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.200.253/24 brd 10.0.200.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::dcba:57ff:fec0:1e0e/64 scope link
       valid_lft forever preferred_lft forever

```

*app pod routing table*
```
/ # ip r
default via 10.0.200.252 dev net1
10.0.0.0/16 via 10.0.200.1 dev net1
10.0.0.2 via 10.0.200.1 dev net1
10.0.200.0/24 dev net1 proto kernel scope link src 10.0.200.253
10.96.0.0/12 via 10.0.200.1 dev net1
169.254.1.1 dev eth0 scope link
/ #

/ # ip route get 1.1.1.1
1.1.1.1 via 10.0.200.252 dev net1 src 10.0.200.253 uid 0
    cache
/ #

```

*app shall able to reach interface via cfos*
```
/ # ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.41 ms
^C
--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.408/1.408/1.408/0.000 ms
/ #
```









- ### scale node

```
eksctl scale nodegroup DemoNodeGroup --cluster EKSDemo -N 3 -M 3
```

*the cfos DS will be deployed on node added EKS node with same configuration*

- ### scale application

```

ADFS-Admin:~/environment $ kubectl scale deployment multitool01-deployment --replicas=4
deployment.apps/multitool01-deployment scaled
(base) ➜  eks git:(main) ✗ kubectl get pod -o wide
NAME                                      READY   STATUS    RESTARTS   AGE   IP            NODE                                        NOMINATED NODE   READINESS GATES
fos-deployment-7z7lq                      1/1     Running   0          12m   10.0.35.90    ip-10-0-56-175.ap-east-1.compute.internal   <none>           <none>
fos-deployment-bpb7p                      1/1     Running   0          27m   10.0.31.162   ip-10-0-23-106.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-779b44cdc4-4t75f   1/1     Running   0          6s    10.0.44.9     ip-10-0-56-175.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-779b44cdc4-5dphs   1/1     Running   0          16m   10.0.58.122   ip-10-0-56-175.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-779b44cdc4-8bhbf   1/1     Running   0          16m   10.0.24.55    ip-10-0-23-106.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-779b44cdc4-v844d   1/1     Running   0          6s    10.0.13.195   ip-10-0-23-106.ap-east-1.compute.internal   <none>           <none>


```

- ### check internet reachability from application pod

```
kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- curl -k -I https://1.1.1.1 ; done

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/2 200
date: Mon, 20 Mar 2023 08:42:54 GMT
content-type: text/html
report-to: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=TKRO02ZjEp6Xxy1V3Tw75fptrtIWNZ%2BPH174Ec6E%2FbCDzKADpaLjyEA9vNZ4VthytW%2FImLGqTZ77DotoEIGWpYVAtWKjfRSSu26FDMXJpC3CrNowZwYvFbA%3D"}],"group":"cf-nel","max_age":604800}
nel: {"report_to":"cf-nel","max_age":604800}
last-modified: Thu, 04 Aug 2022 19:10:01 GMT
strict-transport-security: max-age=31536000
served-in-seconds: 0.003
cache-control: public, max-age=14400
cf-cache-status: HIT
age: 75
expires: Mon, 20 Mar 2023 12:42:54 GMT
set-cookie: __cf_bm=LDx7S5f_xiUaLdgDG25wiuM8VXTYldRMoiwNpBARm3c-1679301774-0-AYibXAdtAaZO4HlyAkIlTQKKG8glaS+YM2uxCFnBnygPdWs/FAJyVH+K26CwrH7bjRPpRuqsE6L6ZkP854bQPUw=; path=/; expires=Mon, 20-Mar-23 09:12:54 GMT; domain=.every1dns.com; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 7aacaa187b8a1056-HKG
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/2 200
date: Mon, 20 Mar 2023 08:42:54 GMT
content-type: text/html
report-to: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=rVK%2Bdx0XhGr%2FzD3oFqpaULOhmwgn7BUlk4fAgAT4p9TqrwmNhfbFQf3xTvPPEPxl1lSMVtCTi4rNY5%2FhJVZUwg9mLtRXG6QoDwQpVNT818acTcSewSWbG34%3D"}],"group":"cf-nel","max_age":604800}
nel: {"report_to":"cf-nel","max_age":604800}
last-modified: Thu, 04 Aug 2022 19:10:01 GMT
strict-transport-security: max-age=31536000
served-in-seconds: 0.002
cache-control: public, max-age=14400
cf-cache-status: HIT
age: 461
expires: Mon, 20 Mar 2023 12:42:54 GMT
set-cookie: __cf_bm=KzTPZkMITS0hRhbVAmaI2ilugYo4dHxqRqfusT20exw-1679301774-0-AUkFSqhQSzz+iYAFojsVaMUu252COREyczMCHOHq84aOY3RfxNmLJ2Q4QVXwq5t3+fTouPnBt/jhOfDcxRR2Whw=; path=/; expires=Mon, 20-Mar-23 09:12:54 GMT; domain=.every1dns.com; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 7aacaa1d1aa98b87-HKG
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/2 200
date: Mon, 20 Mar 2023 08:42:55 GMT
content-type: text/html
report-to: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=fT%2B6M0zd%2FxeB2Jw37WqxlU6tGln7imOwN41XdFps7%2B1m9ZLjbCR%2Bnzau8mG8Uh94WemtssaqvAGygzYc1reghUbLL2%2BHLfKkab4o6Ep98FgxnjO12E7cLLc%3D"}],"group":"cf-nel","max_age":604800}
nel: {"report_to":"cf-nel","max_age":604800}
last-modified: Thu, 04 Aug 2022 19:10:01 GMT
strict-transport-security: max-age=31536000
served-in-seconds: 0.003
cache-control: public, max-age=14400
cf-cache-status: HIT
age: 76
expires: Mon, 20 Mar 2023 12:42:55 GMT
set-cookie: __cf_bm=45azxnCpPeX8EJrRPYKTRLmM8iiwVpDCbuN3jtfbiYk-1679301775-0-ARSD63y1dwyOSVpCdL5wKDdnwPNPAh2NLcGijBakcB5loOjZvMkf+6SuDtcPAF0zgvHRjSQ0XFS20xqfJeRtU1U=; path=/; expires=Mon, 20-Mar-23 09:12:55 GMT; domain=.every1dns.com; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 7aacaa23790f1072-HKG
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/2 200
date: Mon, 20 Mar 2023 08:42:56 GMT
content-type: text/html
report-to: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=WBtXmwUnpeORoBFfMzZ%2Bo%2BcMkIHGXU1lcMMwtxzsWtECuUltcnk3xvrDSejmOY%2FMDixR0SdDA6VrqsiTXneIAK90HggBk0rmTLaXvGnoL4vQti3d81OcqBc%3D"}],"group":"cf-nel","max_age":604800}
nel: {"report_to":"cf-nel","max_age":604800}
last-modified: Thu, 04 Aug 2022 19:10:01 GMT
strict-transport-security: max-age=31536000
served-in-seconds: 0.003
cache-control: public, max-age=14400
cf-cache-status: HIT
age: 349
expires: Mon, 20 Mar 2023 12:42:56 GMT
set-cookie: __cf_bm=h_6eaOsudMamen3O3w4GiWJWzKhAcpsufNAtaZVwpGI-1679301776-0-AUSbGEp/9uHwC3CIue4wioPjzHjqakCW24RJYuQPulVZLiHAdrMDEoB6r2IcRuKPnipTjUzb5hzOHgyP8b/08RU=; path=/; expires=Mon, 20-Mar-23 09:12:56 GMT; domain=.every1dns.com; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 7aacaa27feed0460-HKG
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400

```
- ### check the ping   reachability between PDS

```
(base) ➜  eks git:(main) ✗ k exec -it po/multitool01-deployment-779b44cdc4-4t75f  -- ping -c 1 10.0.44.9
PING 10.0.44.9 (10.0.44.9) 56(84) bytes of data.
64 bytes from 10.0.44.9: icmp_seq=1 ttl=64 time=0.024 ms

--- 10.0.44.9 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.024/0.024/0.024/0.000 ms
(base) ➜  eks git:(main) ✗
(base) ➜  eks git:(main) ✗ k exec -it po/multitool01-deployment-779b44cdc4-4t75f  -- ping -c 1 10.0.58.122
PING 10.0.58.122 (10.0.58.122) 56(84) bytes of data.
64 bytes from 10.0.58.122: icmp_seq=1 ttl=63 time=0.148 ms

--- 10.0.58.122 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.148/0.148/0.148/0.000 ms
(base) ➜  eks git:(main) ✗ k exec -it po/multitool01-deployment-779b44cdc4-4t75f  -- ping -c 1 10.0.24.55
PING 10.0.24.55 (10.0.24.55) 56(84) bytes of data.
64 bytes from 10.0.24.55: icmp_seq=1 ttl=62 time=0.569 ms

--- 10.0.24.55 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.569/0.569/0.569/0.000 ms
(base) ➜  eks git:(main) ✗ k exec -it po/multitool01-deployment-779b44cdc4-4t75f  -- ping -c 1 10.0.13.195
PING 10.0.13.195 (10.0.13.195) 56(84) bytes of data.
64 bytes from 10.0.13.195: icmp_seq=1 ttl=62 time=0.739 ms

--- 10.0.13.195 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.739/0.739/0.739/0.000 ms
```
