- ## Description

This demostration will guide you to setup cfos on EKS cluster with AWS VPC CNI and macvlan CNI. 
application pod will use additional network to communicate with cfos. We will install multus on EKS to manage additional network.



- ## Network Diagram

eth0-application pod--net1---net1--cfos--eth0--internet

*the eth0 interface on POD will be managed by AWS VPC CNI which is the default CNI for EKS*
*the net1 itnerface on POD will be managed by macvlan CNI which is used for application POD send traffic to cFOS*


- ## required iam user for create EKS clustr  

You will use eksctl to create EKS cluster, When you use eksctl to create an Amazon EKS cluster, it requires an IAM user with sufficient permissions. The IAM user should have the following minimum permissions:

AmazonEKSFullAccess: This managed policy provides the necessary permissions to manage EKS clusters.

AmazonEKSClusterPolicy: This managed policy allows creating and managing the resources required for an EKS cluster, such as VPCs, subnets, and security groups.

AmazonEC2FullAccess: This managed policy provides permissions to manage EC2 instances and other related resources, such as key pairs, Elastic IPs, and snapshots.

IAMFullAccess: This managed policy allows eksctl to create and manage IAM roles for your Kubernetes workloads and the Kubernetes control plane.

AmazonVPCFullAccess: This managed policy allows eksctl to create and manage the VPC resources required for the EKS cluster, such as VPCs, subnets, route tables, and NAT gateways.

AWSCloudFormationFullAccess: This managed policy provides eksctl with permissions to create, update, and delete CloudFormation stacks, which are used to manage the infrastructure resources for your EKS cluster.

- ## install eksctl and aws cli  on your client machine

Client machine is any machine that can be used to create EKS cluster, and access EKS. you will need install eksctl and aws cli and config access credentials for AWS cloud. 


eksctl is a command-line tool for creating and managing Amazon EKS clusters. To create an EKS cluster using eksctl, follow these steps:

Install and configure the AWS CLI:
First, make sure you have the AWS CLI installed on your computer. You can download and install it from the official AWS CLI website: https://aws.amazon.com/cli/

Once installed, configure the AWS CLI with your AWS credentials by running:

```
aws configure
```
Enter your Access Key ID, Secret Access Key, default region name, and default output format when prompted.

Install eksctl:
Download and install eksctl following the instructions for your operating system on the official eksctl https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

- ## check your client environment
The `aws iam simulate-principal-policy` command is used to simulate the set of IAM policies attached to a principal (user, group, or role) to test their permissions for specific API actions. This command can help you determine whether a specific principal has the necessary permissions to perform a set of actions.
for example. you shall see result "EvalDecsion": allowed" 

- ## check your client environment 
check below cli command see whether any of them fails 
```
aws --version && eksctl version 
aws configure list
myarn=$(aws sts get-caller-identity --output text | awk '{print $2}')
aws iam simulate-principal-policy --policy-source-arn $myarn --action-names "eks:CreateCluster" "eks:DescribeCluster" "ec2:CreateVpc" "iam:CreateRole" "cloudformation:CreateStack" | grep Eval
```

- ## create ssh key for access eks work node 
paste cli command below in your client terminal to create ssh key if not exist 

```
[ -f ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ''
```
- ## create eks cluster config file for eksctl to use

below is a standard EKS config with all default configuration

*you will need generate your own ssh key , which you can use ssh-keygen and place it under ~/.ssh/id*
*the kubernetes serviceCIDR is 10.96.0.0/12*
*the VPC has subnet 10.0.0.0/16*
*the default region and az is on ap-east-1, you can change to other regions and az if you want*


the kubernetes version is 1.25
paste below script on your client terminal to create eks cluster 

```
cat << EOF | eksctl create cluster -f -
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
- amiFamily: AmazonLinux2
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
  - t3.large
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
    publicKeyPath: ~/.ssh/id_rsa.pub
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

- ### check the EKS cluster that created 

you shall see below output from above command 

```
2023-03-31 11:14:02 [ℹ]  eksctl version 0.134.0
2023-03-31 11:14:02 [ℹ]  using region ap-east-1
2023-03-31 11:14:02 [ℹ]  subnets for ap-east-1b - public:10.0.0.0/19 private:10.0.64.0/19
2023-03-31 11:14:02 [ℹ]  subnets for ap-east-1a - public:10.0.32.0/19 private:10.0.96.0/19
2023-03-31 11:14:02 [ℹ]  nodegroup "DemoNodeGroup" will use "" [AmazonLinux2/1.25]
2023-03-31 11:14:02 [ℹ]  using SSH public key "/Users/i/.ssh/id_rsa.pub" as "eksctl-EKSDemo-nodegroup-DemoNodeGroup-51:77:a9:85:2c:84:79:cb:d9:f7:85:34:4c:20:5f:00"
2023-03-31 11:14:03 [ℹ]  using Kubernetes version 1.25
2023-03-31 11:14:03 [ℹ]  creating EKS cluster "EKSDemo" in "ap-east-1" region with managed nodes
2023-03-31 11:14:03 [ℹ]  1 nodegroup (DemoNodeGroup) was included (based on the include/exclude rules)
2023-03-31 11:14:03 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-03-31 11:14:03 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-03-31 11:14:03 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-east-1 --cluster=EKSDemo'
2023-03-31 11:14:03 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "EKSDemo" in "ap-east-1"
2023-03-31 11:14:03 [ℹ]  CloudWatch logging will not be enabled for cluster "EKSDemo" in "ap-east-1"
2023-03-31 11:14:03 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-east-1 --cluster=EKSDemo'
2023-03-31 11:14:03 [ℹ]
2 sequential tasks: { create cluster control plane "EKSDemo",
    2 sequential sub-tasks: {
        wait for control plane to become ready,
        create managed nodegroup "DemoNodeGroup",
    }
}
2023-03-31 11:14:03 [ℹ]  building cluster stack "eksctl-EKSDemo-cluster"
2023-03-31 11:14:04 [ℹ]  deploying stack "eksctl-EKSDemo-cluster"
2023-03-31 11:14:34 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:15:04 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:16:04 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:17:04 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:18:05 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:19:05 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:20:05 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:21:06 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:22:06 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:23:06 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:24:07 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-cluster"
2023-03-31 11:26:09 [ℹ]  building managed nodegroup stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:26:10 [ℹ]  deploying stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:26:10 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:26:40 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:27:27 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:28:52 [ℹ]  waiting for CloudFormation stack "eksctl-EKSDemo-nodegroup-DemoNodeGroup"
2023-03-31 11:28:53 [ℹ]  waiting for the control plane to become ready
2023-03-31 11:28:53 [✔]  saved kubeconfig as "/Users/i/.kube/config"
2023-03-31 11:28:53 [ℹ]  no tasks
2023-03-31 11:28:53 [✔]  all EKS cluster resources for "EKSDemo" have been created
2023-03-31 11:28:53 [ℹ]  nodegroup "DemoNodeGroup" has 1 node(s)
2023-03-31 11:28:53 [ℹ]  node "ip-10-0-29-226.ap-east-1.compute.internal" is ready
2023-03-31 11:28:53 [ℹ]  waiting for at least 1 node(s) to become ready in "DemoNodeGroup"
2023-03-31 11:28:53 [ℹ]  nodegroup "DemoNodeGroup" has 1 node(s)
2023-03-31 11:28:53 [ℹ]  node "ip-10-0-29-226.ap-east-1.compute.internal" is ready
2023-03-31 11:28:54 [ℹ]  kubectl command should work with "/Users/i/.kube/config", try 'kubectl get nodes'
2023-03-31 11:28:54 [✔]  EKS cluster "EKSDemo" in "ap-east-1" region is ready
```


- ## access the eks cluster from your client machine 
once EKS cluster is ready, a kubeconfig will be modified or created on your client machine which enable you to access the remote cluster. 

*you can  use `eksctl utils write-kubeconfig`  to re-config the kubeconfig file to access eks if you mess-up the configuration*

you shall see a kubernetes cluster with 1 node in ready state, "Ready" status indicate that CNI component is also ready. you can use command 
The aws-node DaemonSet manages the AWS VPC CNI plugin for Kubernetes, which is responsible for assigning AWS VPC IP addresses to Kubernetes pods. To view the environment variables and configuration for the aws-node CNI, you can inspect the aws-node DaemonSet.

```
podname=$(kubectl get pods -n kube-system -l k8s-app=aws-node -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')
kubectl -n kube-system get pod $podname -o jsonpath='{.spec.containers[0].env}' | jq .
```

by default, there is no pod resource in default namespace. 
```
kubectl get node -o wide  & kubectl get pod 
```
you shall see output 
```
✗ kubectl get node -o wide
NAME                                       STATUS   ROLES    AGE    VERSION               INTERNAL-IP   EXTERNAL-IP    OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-14-93.ap-east-1.compute.internal   Ready    <none>   163m   v1.25.7-eks-a59e1f0   10.0.14.93    18.167.17.26   Amazon Linux 2   5.10.173-154.642.amzn2.x86_64   containerd://1.6.6
✗ kubectl get pod
No resources found in default namespace.
```

- ## install multus

Amazon EKS supports Multus, a Container Network Interface (CNI) plugin that enables you to attach multiple network interfaces to your Kubernetes pods. This can be useful for workloads requiring additional network isolation or advanced networking features. In this demo. application pod will use additional network to communicate with cFOS. so we will need install multus with additional CNI. 

To use Multus on Amazon EKS, you'll need to install and configure it manually. Here's a high-level overview of the steps:

Create a VPC and configure the required subnets for your EKS cluster.

Deploy an EKS cluster using eksctl or any other method you prefer.

Install the Multus CNI plugin on your EKS cluster. You can find the installation instructions in the official Multus GitHub repository: https://github.com/k8snetworkplumbingwg/multus-cni#quickstart
In this demo, we will use macvlan as secondary CNI for EKS. the macvlan CNI has installed by default on EKS.so we do not need reinstall macvlan.

Configure your CNI plugins. Multus works as a "meta-plugin" that calls other CNI plugins. You'll need to have at least one additional CNI plugin installed and configured. Popular choices include Flannel, Calico, and Weave. You can find a list of CNI plugins here: https://github.com/containernetworking/plugins

Create NetworkAttachmentDefinition custom resources (CRs) that define the network configuration for your additional network interfaces. Here's an example:

```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "eth1",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "rangeStart": "10.1.200.20",
        "rangeEnd": "10.1.200.50",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ],
        "gateway": "10.1.200.1"
      }
    }'

```
copy and poast below code to your client terminal to install multus-cni.
```
git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni
cat ./deployments/multus-daemonset.yml | kubectl apply -f -
```
you shall see  below output

```
➜  eks git:(main) ✗ git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni
Cloning into 'multus-cni'...
remote: Enumerating objects: 39809, done.
remote: Counting objects: 100% (267/267), done.
remote: Compressing objects: 100% (185/185), done.
remote: Total 39809 (delta 87), reused 217 (delta 69), pack-reused 39542
Receiving objects: 100% (39809/39809), 49.75 MiB | 763.00 KiB/s, done.
Resolving deltas: 100% (18315/18315), done.
➜  multus-cni git:(master) cat ./deployments/multus-daemonset.yml | kubectl apply -f -
customresourcedefinition.apiextensions.k8s.io/network-attachment-definitions.k8s.cni.cncf.io created
clusterrole.rbac.authorization.k8s.io/multus created
clusterrolebinding.rbac.authorization.k8s.io/multus created
serviceaccount/multus created
configmap/multus-cni-config created
daemonset.apps/kube-multus-ds created

```

- ## check the multus instalation 

```
kubectl rollout status ds/kube-multus-ds -n kube-system
```

- ## chech the multus cni now become the default cni for EKS on work node

you will see that cni name is "multus-cni-network" with delegate to "aws-cni" 

```
➜  010-eks git:(main) ✗ kubectl get node -o wide
NAME                                       STATUS   ROLES    AGE    VERSION               INTERNAL-IP   EXTERNAL-IP    OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-14-93.ap-east-1.compute.internal   Ready    <none>   141m   v1.25.7-eks-a59e1f0   10.0.14.93    18.167.17.26   Amazon Linux 2   5.10.173-154.642.amzn2.x86_64   containerd://1.6.6
➜  010-eks git:(main) ✗ ssh ec2-user@18.167.17.26
Last login: Mon Apr  3 01:59:32 2023 from 115.197.132.80

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-10-0-14-93 ~]$ sudo su
[root@ip-10-0-14-93 ec2-user]# cat /etc/cni/net.d/00-multus.conf | jq .
{
  "cniVersion": "0.3.1",
  "name": "multus-cni-network",
  "type": "multus",
  "capabilities": {
    "portMappings": true
  },
  "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig",
  "delegates": [
    {
      "cniVersion": "0.4.0",
      "name": "aws-cni",
      "disableCheck": true,
      "plugins": [
        {
          "name": "aws-cni",
          "type": "aws-cni",
          "vethPrefix": "eni",
          "mtu": "9001",
          "podSGEnforcingMode": "strict",
          "pluginLogFile": "/var/log/aws-routed-eni/plugin.log",
          "pluginLogLevel": "DEBUG"
        },
        {
          "name": "egress-v4-cni",
          "type": "egress-v4-cni",
          "mtu": 9001,
          "enabled": "false",
          "randomizeSNAT": "prng",
          "nodeIP": "10.0.14.93",
          "ipam": {
            "type": "host-local",
            "ranges": [
              [
                {
                  "subnet": "169.254.172.0/22"
                }
              ]
            ],
            "routes": [
              {
                "dst": "0.0.0.0/0"
              }
            ],
            "dataDir": "/run/cni/v6pd/egress-v4-ipam"
          },
          "pluginLogFile": "/var/log/aws-routed-eni/egress-v4-plugin.log",
          "pluginLogLevel": "DEBUG"
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          },
          "snat": true
        }
      ]
    }
  ]
}
[root@ip-10-0-14-93 ec2-user]#

```
- ## Create  multus crd on EKS for application and cfos to attach 

We need create additional network for application pod to communicate with cFOS. we use multus CRD to create this. 

*the API for this CRD is k8s.cni.cncf.io/v1* 
*this is a CRD which has kind "NetworkAttachmentDefinition*
*the CRD has name cfosdefaultcni5*.
*inside CRD, it include the json formatted cni configuration, it is the actual cni configuration, the macvlan binary will parse this json*
*the cni use macvlan*
*the cni mode is bridge*
*"master interface for this maclan is eth0, so EKS will not create additional ENI as we only use this network for communication between applicaton POD to cFOS POD*
*the ipam is host-local*

copy and paste below code to your terminal window

```
cat << EOF | kubectl create -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: cfosdefaultcni5
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "eth0",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.1.200.0/24",
        "rangeStart": "10.1.200.20",
        "rangeEnd": "10.1.200.253",
        "gateway": "10.1.200.1"
      }
    }'
EOF
```
- ### check the crd installation

```
✗ kubectl get net-attach-def cfosdefaultcni5 -o yaml
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  creationTimestamp: "2023-03-31T03:53:31Z"
  generation: 1
  name: cfosdefaultcni5
  namespace: default
  resourceVersion: "5700"
  uid: 2e8127d2-4dd5-4c8d-b1c4-c43a7f78ecbd
spec:
  config: '{ "cniVersion": "0.3.0", "type": "macvlan", "master": "eth0", "mode": "bridge",
    "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "rangeStart": "10.1.200.20",
    "rangeEnd": "10.1.200.253", "gateway": "10.1.200.1" } }'
```

- ### install docker secret to pull cfos image from docker repository

Assume you have build your cfos image and saved on your private repository for example like docker hub. then you will need create secret to pull cfos image
please follow <TODO> to create a docker secret yaml manifest. 

```
kubectl create -f dockersecret.yaml
```

check the result 
```
➜  eks git:(main) ✗ kubectl create -f dockersecret.yaml
secret/dockerinterbeing created
➜  eks git:(main) ✗ kubectl get secret
NAME               TYPE                             DATA   AGE
dockerinterbeing   kubernetes.io/dockerconfigjson   1      8s
➜  eks git:(main) ✗


```
- ###  create a configmap with cfos license
*cfos require a license to be functional. the license can be configured use cfos cli or use kubernetes configmap*
*cfos will use kubenetes API to read the configmap once cfos start*
*once cFOS container boot up, it will read the configmap to obtain the license*
*cfos license configmap has below format*

replace "past your base64 encoded license here" with you actual license data to create your configmap for license , then create the configmap from license file.

```
cat << EOF > fos_license.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: fos-license
    labels:
        app: fos
        category: license
data:
    license: |
     -----BEGIN FGT VM LICENSE-----
     paste your base64 encoded license here
     -----END FGT VM LICENSE-----
EOF
kubectl create -f fos_license.yaml
```
you shall see output 
```
configmap/fos-license created
➜ ✗ kubectl get cm fos-license
NAME          DATA   AGE
fos-license   1      30s
```

- ### create role for cfos 

*cfos pod  will need permission to communicate with kubernetes API to read the configmap and also need able to read secret to pull docker image 
so we need assign role with permission to cfos POD based on least priviledge principle*
*below we create ClusterRole to read configmaps and secrets and bind them to default serviceaccount* 
*when we create cfos POD with default serviceaccount, the pod will have permission to read configmap and secret*

copy and paste below code to your client terminal window to create role for cFOS

```
cat << EOF | kubectl create -f - 
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

you shall see  output like below

```
clusterrole.rbac.authorization.k8s.io/configmap-reader created
rolebinding.rbac.authorization.k8s.io/read-configmaps created
clusterrole.rbac.authorization.k8s.io/secrets-reader created
rolebinding.rbac.authorization.k8s.io/read-secrets created
```

- ### create cfos daemonSet

*we will create cfos as daemonSet, so each node will have single cfos POD*
*cfos will be attached to net-attach-def CRD which created in previous step*
*cfos configured a clusterIP service for restapi port*
*cfos use annotation to attach to crd. the "k8s.v1.cni.cncf.io/networks" means for secondary network, the default interface inside cfos will be net1 by default*
*cfos will have fixed ip "10.1.200.252/32" which is the range of crd cni configuration*
*cfos can also have a fixed mac address*
*the linux capabilities NET_ADMIN, SYS_AMDIN, NET_RAW are required for use ping, sniff and syslog*
*the cfos image will be pulled from docker hub with pull secret*
*the  cfos container mount /data to a directory in host work node, the /data save license, and configuration file etc.,*
*you need to change the line "image: interbeing/fos:v7231x86 to your actual image respository*

copy and paste below code to your terminal window to create cfos DaemonSet
```
cat << EOF | kubectl create -f - 
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
- ### chech the cfos daemonSet deployment


```
kubectl get ds fos-deployment
```
you shall see 
```
NAME             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
fos-deployment   1         1         1       1            1           <none>          60s
```

```
kubectl rollout status ds fos-deployment
```
you shall see 
daemon set "fos-deployment" successfully rolled out
```
kubectl get pod
```
you shall see 1 cFOS pod is in ready and is Running 
```
NAME                   READY   STATUS    RESTARTS   AGE
fos-deployment-x8vzj   1/1     Running   0          2m37s

```

- ### check cfos container log

below you will see that cfos container have sucessfully load the license from configmap and system is ready

copy and paste below command to check cFOS license 

```
kubectl logs -f $(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}')
```

below you will see that cfos container have sucessfully load the license from configmap and system is ready
```
System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
INFO: 2023/03/31 05:37:02 importing license...
INFO: 2023/03/31 05:37:02 license is imported successfuly!
WARNING: System is running in restricted mode due to lack of valid license!
Starting services...
System is ready.

2023-03-31_05:37:03.20787 ok: run: /run/fcn_service/certd: (pid 301) 0s, normally down
2023-03-31_05:37:08.25153 INFO: 2023/03/31 05:37:08 received a new fos configmap
2023-03-31_05:37:08.25158 INFO: 2023/03/31 05:37:08 configmap name: fos-license, labels: map[app:fos category:license]
2023-03-31_05:37:08.25158 INFO: 2023/03/31 05:37:08 got a fos license
```

- ### check the ip address and routing table of cfos container 
below you will see cfos container has eth0 and net1 interface

net1 interface is created by macvlan cni

eth0 interface is created by aws vpc cni

*cfos container have default route point to 169.254.1.1 which has fixed mac address from veth pair interface on the host side (enixxx interface on host)*

paste below command to check cfos ip address 

```
cfospodname=$(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it po/$cfospodname -- ip a
```

the output shall like below. you will expect see different ip address on eth0. but the net1 ip address shall be 10.1.200.252. 

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 7e:55:44:3d:62:fa brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.19.107/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::7c55:44ff:fe3d:62fa/64 scope link
       valid_lft forever preferred_lft forever
4: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 8e:2c:2a:6b:90:49 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.200.252/24 brd 10.1.200.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::8c2c:2aff:fe6b:9049/64 scope link
       valid_lft forever preferred_lft forever

```
paste below command to check ip routing table 

```
cfospodname=$(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it po/$cfospodname -- ip route
```

the output will be 
```
default via 169.254.1.1 dev eth0
10.1.200.0/24 dev net1 proto kernel scope link src 10.1.200.252
169.254.1.1 dev eth0 scope link
```

- ### check cfos POD description
*the serviceAccount is default which granted read configmap and secret in previous step*
*the annotations usr k8s.v1.cni.cncf.io/networks to tell CRD to assign IP for it*
*in the events log, the interface eth0 and net1 are from multus which means multus is the default CNI for eks*
*multus delegate to aws-cni for eth0 interface, multus delegate to macvlan cni for net1 interface*

```
cfospodname=$(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}')
kubectl describe po/$cfospodname
```

the output shall looks like below 
```
Name:             fos-deployment-x8vzj
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-10-0-29-226.ap-east-1.compute.internal/10.0.29.226
Start Time:       Fri, 31 Mar 2023 13:36:55 +0800
Labels:           app=fos
                  controller-revision-hash=6555fcd587
                  pod-template-generation=1
Annotations:      k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "aws-cni",
                        "interface": "dummydb68da92e6e",
                        "ips": [
                            "10.0.19.107"
                        ],
                        "mac": "0",
                        "default": true,
                        "dns": {}
                    },{
                        "name": "default/cfosdefaultcni5",
                        "interface": "net1",
                        "ips": [
                            "10.1.200.252"
                        ],
                        "mac": "8e:2c:2a:6b:90:49",
                        "dns": {}
                    }]
                  k8s.v1.cni.cncf.io/networks: [ { "name": "cfosdefaultcni5",  "ips": [ "10.1.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]
                  k8s.v1.cni.cncf.io/networks-status:
                    [{
                        "name": "aws-cni",
                        "interface": "dummydb68da92e6e",
                        "ips": [
                            "10.0.19.107"
                        ],
                        "mac": "0",
                        "default": true,
                        "dns": {}
                    },{
                        "name": "default/cfosdefaultcni5",
                        "interface": "net1",
                        "ips": [
                            "10.1.200.252"
                        ],
                        "mac": "8e:2c:2a:6b:90:49",
                        "dns": {}
                    }]
Status:           Running
IP:               10.0.19.107
IPs:
  IP:           10.0.19.107
Controlled By:  DaemonSet/fos-deployment
Containers:
  fos:
    Container ID:   containerd://b12c9e732116597d37e70ee61cbc6fc3ec390597280eecb97ed29a482bdef083
    Image:          interbeing/fos:v7231x86
    Image ID:       docker.io/interbeing/fos@sha256:96b734cf66dcf81fc5f9158e66676ee09edb7f3b0f309c442b48ece475b42e6c
    Ports:          500/UDP, 4500/UDP
    Host Ports:     0/UDP, 0/UDP
    State:          Running
      Started:      Fri, 31 Mar 2023 13:37:02 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from data-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xxs26 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  data-volume:
    Type:          HostPath (bare host directory volume)
    Path:          /cfosdata
    HostPathType:  DirectoryOrCreate
  kube-api-access-xxs26:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type    Reason          Age   From               Message
  ----    ------          ----  ----               -------
  Normal  Scheduled       14m   default-scheduler  Successfully assigned default/fos-deployment-x8vzj to ip-10-0-29-226.ap-east-1.compute.internal
  Normal  AddedInterface  14m   multus             Add eth0 [10.0.19.107/32] from aws-cni
  Normal  AddedInterface  14m   multus             Add net1 [10.1.200.252/24] from default/cfosdefaultcni5
  Normal  Pulling         14m   kubelet            Pulling image "interbeing/fos:v7231x86"
  Normal  Pulled          14m   kubelet            Successfully pulled image "interbeing/fos:v7231x86" in 5.773955482s (5.77396476s including waiting)
  Normal  Created         14m   kubelet            Created container fos
  Normal  Started         14m   kubelet            Started container fos
```



- ### check cfos configuration use cfos cli
*at this moment, cfos has no configuration but a license*
*use fcnsh enter cfos shell*
*use sysctl sh go back to sh*

```
cfospodname=$(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it po/$cfospodname -- sh
``` 
you will be dropped into the shell. then type  `fcnsh` to enter cFOS shell
```
fcnsh
```
you will see  cFOS cli interface, where you can use fortiOS cli 

```
FOS Container # show firewall policy
config firewall policy
end

FOS Container # show firewall addrgrp
config firewall addrgrp
end
FOS Container # sysctl sh
#
``` 

you can use `sysctl sh` command back to cFOS container linux shell

```
FOS Container # sysctl sh
# exit
```

- ### create demo application deployment 

the replicas=4 mean it will create 4 POD on this work node

annotations k8s.v1.cni.cncf.io/networks to tell CRD to attach the pod to network cfosdefaultcni5 with net1 interface

the POD will get default-route 10.1.200.252 which is the ip of cfos on net1 interface

the net1 interface use network cfosdefaultcni5 to communicate with cfos net1

*the POD need to install a route for 10.0.0.0/16 subnet with nexthop to 169.254.1.1, as these traffic do not want goes to cfos, if remove this route, pod to pod communication will be send to cFOS as well*


copy and paste below script on your client terminal to create application deployment, we label the pod will label app=multitool01

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
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
          imagePullPolicy: Always
          args:
            - /bin/sh
            - -c
            - ip route add 10.0.0.0/16  via 169.254.1.1; /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF
```
- ### check the deployment result 

```
kubectl rollout status deployment multitool01-deployment
```
you shall see 
```
deployment "multitool01-deployment" successfully rolled out
```
check the pod status 
```
kubectl get pod -l app=multitool01
```
you shall see 
```
NAME                                     READY   STATUS    RESTARTS   AGE
multitool01-deployment-88ff6b48c-d2drz   1/1     Running   0          33s
multitool01-deployment-88ff6b48c-klx2z   1/1     Running   0          33s
multitool01-deployment-88ff6b48c-pzssg   1/1     Running   0          33s
multitool01-deployment-88ff6b48c-t97t6   1/1     Running   0          33s
```

- ### create another deployment with different label
we want demo to support multiple application based on the label. so we create one more deployment with different label.
paste below script to create another deployment, we assign label to pod app=newtest 

```
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testtest-deployment
  labels:
      app: newtest
spec:
  replicas: 2
  selector:
    matchLabels:
        app: newtest
  template:
    metadata:
      labels:
        app: newtest
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'
    spec:
      containers:
        - name: newtest
          image: praqma/network-multitool
          imagePullPolicy: Always
          args:
            - /bin/sh
            - -c
            - ip route add 10.0.0.0/16  via 169.254.1.1; /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF
```


- ### create a pod to manage the networkpolicy and keep update pod ip address to cfos firewall policy 

we create a pod with name clientpod to create firewall policy for cFOS and it will also keep POD IP address in sync between cFOS and kubernetes.
as POD ip address is not fixed. the IP address will change due to scale , restart etc . we will keep the the POP ip address in sync with cFOS addressgroup.
basically, this clientpod will  

create firewall policy for two deployment which has annotations to use cfosdefaultcni5 netwok

update application pod ip address to cfos addressgroup.

privode pod address update for the firewall policy that created by gatekeeper, if the policy already created by gatekeeper then, it will only update the POD ip address to cFOS addreegroup.

this pod use image which is build use docker build . you can use Dockerfile to build image and modify the script

this pod also monitor the node number change, if work node increased or decreased ,it will restart cfos DaemonSet.


copy and paste below script to your terminal window to create clientpod. this clientpod is mainly use kubectl client to obtain the POD ip address with label and namespace, then use curl to update the cFOS addressgroup to keep the ip address in cFOS to sync with application POD in kubernetes. I have already build the image for this clientpod and put it on dockerhub. so we can directly create POD with that image. 

```
cat << EOF | kubectl create -f -
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
  name: clientpod
spec:
  serviceAccountName: pod-reader
  containers:
  - name: kubectl-container
    image: interbeing/kubectl-cfos:latest
EOF 

```
- ### check both deployment now shall able to access internet via cfos 

```
➜  ✗ kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.09 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.092/1.092/1.092/0.000 ms
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.04 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.035/1.035/1.035/0.000 ms
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=0.959 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.959/0.959/0.959/0.000 ms
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.16 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.156/1.156/1.156/0.000 ms

➜  ✗ kubectl get pod | grep testtest | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=0.987 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.987/0.987/0.987/0.000 ms
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=51 time=1.05 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.054/1.054/1.054/0.000 ms

```

- ## check cfos firewall addressgroup
*the firewall addrgrp has each POD IP in the group*

```
FOS Container # show firewall addrgrp
config firewall addrgrp
    edit "defaultappmultitool"
        set member 10.1.200.21 10.1.200.22 10.1.200.253 10.1.200.20
    next
    edit "defaultappnewtest"
        set member 10.1.200.24 10.1.200.23
    next
end
```

- ## check cfos firewall policy
```
FOS Container # show firewall policy
config firewall policy
    edit "101"
        set utm-status enable
        set name "corptraffic101"
        set srcintf any
        set dstintf eth0
        set srcaddr defaultappmultitool
        set dstaddr all
        set service ALL
        set ssl-ssh-profile "deep-inspection"
        set av-profile "default"
        set webfilter-profile "default"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
    edit "102"
        set utm-status enable
        set name "corptraffic102"
        set srcintf any
        set dstintf eth0
        set srcaddr defaultappnewtest
        set dstaddr all
        set service ALL
        set ssl-ssh-profile "deep-inspection"
        set av-profile "default"
        set webfilter-profile "default"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
end

```
- ### verify whether cFOS is in health state 

the cFOS might running to into some SSL related issue which is tobefixed, if that happen, use below script to fix it 
```
#!/bin/bash

# Get list of node names
node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')


for nodeName in $node_list; do
        kubectl rollout status deployment multitool01-deployment
        cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
        multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`
        result=$(kubectl exec -it po/$multpod -- curl -k  https://1.1.1.1 2>&1 | grep -o 'decryption failed or bad record mac')
        if [ "$result" = "decryption failed or bad record mac" ]
        then
        echo "cfos is not ready, delete cfos pod"
        kubectl delete po/$cfospod
        else
                echo " on $nodeName cfos is ready"

        fi
done
```
- ### demo cfos l7 security feature -Web Filter feature 
use below script to access eicar to simulate access malicous website from two deployment 
```
 kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.eicar.org/download/eicar.com.txt  ; done
 kubectl get pod -l app=newtest | grep "Running" | awk '{print $1}' | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.eicar.org/download/eicar.com.txt  ; done
```
you will see that cFOS will block it  with 403 Forrbidden

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0HTTP/1.1 403 Forbidden
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: frame-ancestors 'self'
Content-Type: text/html; charset="utf-8"
Content-Length: 5211
Connection: Close
```
- ### check the webfilter log on cFOS
```
kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
```
you shall see 
```
➜  ✗ kubectl get pod | grep fos | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- tail  /data/var/log/log/webf.0  ; done
date=2023-04-03 time=03:05:52 eventtime=1680491152 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=53 srcip=10.1.200.253 srcport=38450 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-04-03 time=03:05:54 eventtime=1680491154 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=101 sessionid=60 srcip=10.1.200.21 srcport=43926 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-04-03 time=03:07:42 eventtime=1680491262 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=102 sessionid=10 srcip=10.1.200.24 srcport=34526 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
date=2023-04-03 time=03:07:43 eventtime=1680491263 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=102 sessionid=72 srcip=10.1.200.23 srcport=37876 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"
```

- ### scale the app deployment 
we scale replicas from 2 to 4 for testtest-deployment which has label app=newtest, the firewall addrgroup name is created by clientpod 
by combine the namespace and label which is defaultappnewtest. 
```
➜  ✗ kubectl scale deployment testtest-deployment --replicas=4
deployment.apps/testtest-deployment scaled

➜  ✗ kubectl get pod -l app=newtest
NAME                                   READY   STATUS    RESTARTS   AGE
testtest-deployment-5768f678d7-4b4wf   1/1     Running   0          110s
testtest-deployment-5768f678d7-8m52w   1/1     Running   0          12m
testtest-deployment-5768f678d7-nxlvq   1/1     Running   0          110s
testtest-deployment-5768f678d7-vdmv5   1/1     Running   0          12m
```
- ### check cfos firewall addressgroup has also updated 
*the addressgroup defaultappnewtest now have 4 member pod ip*

```
FOS Container # show firewall addrgrp
config firewall addrgrp
    edit "defaultappmultitool"
        set member 10.1.200.21 10.1.200.22 10.1.200.253 10.1.200.20
    next
    edit "defaultappnewtest"
        set member 10.1.200.25 10.1.200.24 10.1.200.26 10.1.200.23
    next
end
```

- ### use eksctl to scale nodes
we scale the node to 2 nodes. aws will use autoscalling group to luanch new work node and join kubernetes cluster. it will take sometime. 


```
 eksctl scale nodegroup DemoNodeGroup --cluster EKSDemo -N 2 -M 2 --region ap-east-1

➜  ✗ eksctl scale nodegroup DemoNodeGroup --cluster EKSDemo -N 2 -M 2 --region ap-east-1
2023-03-31 14:51:51 [ℹ]  scaling nodegroup "DemoNodeGroup" in cluster EKSDemo
2023-03-31 14:51:53 [ℹ]  waiting for scaling of nodegroup "DemoNodeGroup" to complete
2023-03-31 14:52:23 [ℹ]  nodegroup successfully scaled


➜  eks git:(main) ✗ kubectl get node
NAME                                        STATUS   ROLES    AGE     VERSION
ip-10-0-29-226.ap-east-1.compute.internal   Ready    <none>   3h25m   v1.25.7-eks-a59e1f0
ip-10-0-39-35.ap-east-1.compute.internal    Ready    <none>   31s     v1.25.7-eks-a59e1f0

```
- ### check new cfos DaemonSet on new work node

```
  ✗ k get pod -o wide
NAME                                     READY   STATUS    RESTARTS   AGE    IP            NODE                                        NOMINATED NODE   READINESS GATES
clientpod                                1/1     Running   0          24m    10.0.1.1      ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
fos-deployment-6zwrj                     1/1     Running   0          90s    10.0.15.143   ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
fos-deployment-zpbmc                     1/1     Running   0          2m2s   10.0.40.52    ip-10-0-39-35.ap-east-1.compute.internal    <none>           <none>
multitool01-deployment-88ff6b48c-d2drz   1/1     Running   0          49m    10.0.9.6      ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-klx2z   1/1     Running   0          49m    10.0.30.9     ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-pzssg   1/1     Running   0          49m    10.0.22.96    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-t97t6   1/1     Running   0          49m    10.0.31.97    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
testtest-deployment-5768f678d7-4b4wf     1/1     Running   0          13m    10.0.4.206    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
testtest-deployment-5768f678d7-8m52w     1/1     Running   0          24m    10.0.18.189   ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
testtest-deployment-5768f678d7-nxlvq     1/1     Running   0          13m    10.0.20.149   ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
testtest-deployment-5768f678d7-vdmv5     1/1     Running   0          24m    10.0.30.19    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>

```

- ### scale out application to use new node 

```
✗ kubectl scale deployment multitool01-deployment --replicas=8
deployment.apps/multitool01-deployment scaled
✗ kubectl get pod -l app=multitool01
NAME                                     READY   STATUS    RESTARTS   AGE
multitool01-deployment-88ff6b48c-d2drz   1/1     Running   0          51m
multitool01-deployment-88ff6b48c-ggr46   1/1     Running   0          22s
multitool01-deployment-88ff6b48c-klx2z   1/1     Running   0          51m
multitool01-deployment-88ff6b48c-p8w46   1/1     Running   0          22s
multitool01-deployment-88ff6b48c-pzssg   1/1     Running   0          51m
multitool01-deployment-88ff6b48c-r5thd   1/1     Running   0          22s
multitool01-deployment-88ff6b48c-t7zqp   1/1     Running   0          22s
multitool01-deployment-88ff6b48c-t97t6   1/1     Running   0          51m
✗ kubectl get pod -l app=multitool01 -o wide
NAME                                     READY   STATUS    RESTARTS   AGE   IP            NODE                                        NOMINATED NODE   READINESS GATES
multitool01-deployment-88ff6b48c-d2drz   1/1     Running   0          51m   10.0.9.6      ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-ggr46   1/1     Running   0          26s   10.0.46.50    ip-10-0-39-35.ap-east-1.compute.internal    <none>           <none>
multitool01-deployment-88ff6b48c-klx2z   1/1     Running   0          51m   10.0.30.9     ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-p8w46   1/1     Running   0          26s   10.0.35.118   ip-10-0-39-35.ap-east-1.compute.internal    <none>           <none>
multitool01-deployment-88ff6b48c-pzssg   1/1     Running   0          51m   10.0.22.96    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
multitool01-deployment-88ff6b48c-r5thd   1/1     Running   0          26s   10.0.46.178   ip-10-0-39-35.ap-east-1.compute.internal    <none>           <none>
multitool01-deployment-88ff6b48c-t7zqp   1/1     Running   0          26s   10.0.63.68    ip-10-0-39-35.ap-east-1.compute.internal    <none>           <none>
multitool01-deployment-88ff6b48c-t97t6   1/1     Running   0          51m   10.0.31.97    ip-10-0-29-226.ap-east-1.compute.internal   <none>           <none>
```

- ### how to build clientpod 

you can modify the clientpod image by build it with Dockerfile or podman etc., if you want to enhance it for your own needs.

```
cat << EOF > Dockerfile
FROM alpine:latest
RUN apk add --no-cache curl jq tar bash ca-certificates
ARG KUBECTL_VERSION="v1.25.0"
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

COPY script.sh /script.sh
RUN chmod +x /script.sh
ENTRYPOINT ["/script.sh"]
EOF
```

here we use docker build to build image, and push to image repository 
replace the repo with your own repo.

```
repo="interbeing/kubectl-cfos:latest"
docker build . -t $repo; docker push $repo
```
- ### the bash script 

the script.sh file also provided as an example for your reference. you can improve it.

```
cat <<EOF >script.sh
function restartcfosifnodenumberchanaged {
previous_node_count=$(kubectl get nodes -o json | jq '.items | length')
echo $previous_node_count

while true; do
  node_count=$(kubectl get nodes -o json | jq '.items | length')

  if [ "$previous_node_count" -ne "$node_count" ]; then
    echo "Number of nodes changed: $node_count"
    echo "restart fos-deployment"
    kubectl rollout status ds/kube-multus-ds -n kube-system
    sleep 30
    kubectl rollout restart ds/fos-deployment
    previous_node_count="$node_count"
  fi
  sleep 180 
  echo "watch node number change"
done
}

function getCfosPodIp {
cfospodips=($(kubectl get pods -l app=fos -o json | jq -r '.items[].status.podIP'))
echo cfospodips
}


function getPolicyId {
policyid=$(kubectl get K8sEgressNetworkPolicyToCfosUtmPolicy cfosnetworkpolicy -o jsonpath='{.spec.parameters.policyid}')
echo $policyid
}

function getPolicyIdFromCfos {
curl -s \
     -X GET "http://${cfosurl}/api/v2/cmdb/firewall/policy"  \
     -H 'Content-Type: application/json' \
      | jq '.results[] | select(.srcaddr[].name == "'"${SRC_ADDR_GROUP}"'") | .policyid'

}

function getPolicyNameFromCfos {
curl -s \
     -X GET "http://${cfosurl}/api/v2/cmdb/firewall/policy"  \
     -H 'Content-Type: application/json' \
      | jq '.results[] | select(.srcaddr[].name == "'"${SRC_ADDR_GROUP}"'") | .name'

}

function getPodApplabel {
        label_value=$(kubectl get pods -o json -A | jq -r '[.items[] | select(.metadata.annotations != null and .metadata.annotations["k8s.v1.cni.cncf.io/networks"] != null and (.metadata.annotations["k8s.v1.cni.cncf.io/networks"] | (contains("cfosdefaultcni5") and contains("default-route")))) | "app=" + .metadata.labels.app] | unique[]')

	LABEL_SELECTOR=$(echo $label_value)
	echo $LABEL_SELECTOR
}

function getPodNamespace {
namespace=$(kubectl get pods -o json -A | jq -r '[.items[] | select(.metadata.annotations != null and .metadata.annotations["k8s.v1.cni.cncf.io/networks"] != null and (.metadata.annotations["k8s.v1.cni.cncf.io/networks"] | (contains("cfosdefaultcni5") and contains("default-route")))) | .metadata.namespace] | unique[]')
        echo $namespace
}


function curltocfosupdatefirewalladdress {
  for ip in "${cfospodips[@]}"; do
  cfosurl=$ip
  #cfosurl=http://fos-deployment.default.svc.cluster.local
  curl -H "Content-Type: application/json" -X POST -d '{ "data": {"name": "'$IP'", "subnet": "'$IP' 255.255.255.255"}}' http://$cfosurl/api/v2/cmdb/firewall/address
  done 
}

function updatecfosfirewalladdress {
  getCfosPodIp
  echo updatecfosfirewalladdress IP=$IP
  curltocfosupdatefirewalladdress

}

function curltocfosupdatefirewalladdrgrp {
      for ip in "${cfospodips[@]}"; do
      cfosurl=$ip
      curl \
                  -H "Content-Type: application/json" \
                  -X PUT \
                  -d '{"data": {"name": "'$SRC_ADDR_GROUP'", "member": '$memberlist', "exclude": "disable", "exclude-member": [ {"name": "'$EXECLUDEIP'"}]}}' \
                  http://$cfosurl/api/v2/cmdb/firewall/addrgrp
                  #http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp
      done
}

function updatecfosfirewalladdressgroup {
                local memberlist="$1"
                echo memberlist=$memberlist
                getCfosPodIp
                if curltocfosupdatefirewalladdrgrp
                then
                  echo $memberlist added to cfos
                  old_POD_IPS=$POD_IPS
                fi               
}

function createcfosfirewallpolicy {
      echo cfospodips=$cfospodips
      echo policyid=$policyid
      echo policyname=$policyname
      echo addrgrpname=$SRC_ADDR_GROUP
      echo cfosurl=$cfosurl
      for ip in "${cfospodips[@]}"; do
      cfosurl=$ip
              if  curl \
               -s \
               -H "Content-Type: application/json" \
               -X POST \
               -d '{ "data": 
                     { "policyid": "'$policyid'",
                       "name":     "'$policyname'",
                       "srcintf": [{"name": "any"}], 
                       "dstintf": [{"name": "eth0"}], 
                       "srcaddr": [{"name": "'$SRC_ADDR_GROUP'"}],
                       "service": [{"name": "ALL"}],
                       "nat":"enable",
                       "utm-status":"enable",
                       "action": "accept",
                       "logtraffic": "all",
                       "ssl-ssh-profile": "deep-inspection",
                       "ips-sensor": "default",
                       "webfilter-profile": "default",
                       "av-profile": "default",
                       "dstaddr": [{"name": "all"}]}}' \
                http://$cfosurl/api/v2/cmdb/firewall/policy
              then 
                echo $policyname $policyid with $SRC_ADDR_GROUP created on cfos $ip
              fi
      done
  
}


function getPodNet1Ips {
 #kubectl get pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' '
 kubectl get pods -n "$currentNAMESPACE" -l "$currentLABEL" -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' '
}


function createClientPod {
  while true; do
  if kubectl get pod clientpod 
  then 
  break
  else 
      kubectl run clientpod --image=praqma/network-multitool
  fi
  done
}

function updateCfos {
                #local POD_IPS="$1"
                echo updateCfos got $POD_IPS 
               # Convert the space-separated list of IP addresses to an array
                read -ra IP_ARRAY <<< "$POD_IPS"
                MEMBER=""
                MEMBER1=""
                
                for IP in "${IP_ARRAY[@]}"; do

                    IP_LIST+=("$IP")
                    echo "New pod IP address detected: $IP, update cfos firewall address"
                    echo IP=$IP

                    updatecfosfirewalladdress

                    MEMBER='{"name":"'$IP'"},'
                    MEMBER1+=$MEMBER

                done
              
               if [ -z "$IP" ]; then 
               echo $IP is empty
               else 
               memberlist="[$(echo "$MEMBER1" | sed 's/,$//')]"
                EXECLUDEIP="none"
                echo call updatecfosfirewalladdressgroup $memberlist
                updatecfosfirewalladdressgroup $memberlist
               fi
                
}

function watchPodandUpdateCfosFirwallAddressGrpforSelectedNamespaceandLabel1() {
 local mynamespace="$1"
 local mylabel="$2"

IP_LIST=()
old_POD_IPS=$(getPodNet1Ips )
while true; do

          POD_IPS=$(getPodNet1Ips )
          if [ "$POD_IPS" != "$old_POD_IPS" ]; then
          
              updateCfos #$POD_IPS
              policyid=$(getPolicyIdFromCfos)
              policyname=$(getPolicyNameFromCfos)
	      createcfosfirewallpolicyifnogatekeeperpolicyexist
                
         fi  
                sleep $INTERVAL
                echo "loop for  detect POD in '$currentNAMESPACE' '$currentLABEL' for ip changing"
        
done
}

function createcfosfirewallpolicyifnogatekeeperpolicyexist {
if [[ -n $(getPolicyId ) ]] ; then  
echo "policy already created by gatekeeper"
else 

echo "calling createcfosfirewallpolicy with policyid $policyid policyname $policyname for $SRC_ADDR_GROUP"
createcfosfirewallpolicy
fi
}

NAMESPACE=$(getPodNamespace)
DEPLOYMENT_NAME="multitool01-deployment"
echo NAMESPACE=$NAMESPACE


LABEL_SELECTOR=$(getPodApplabel)
echo LABEL=$LABEL_SELECTOR

INTERVAL=10


read -ra NAMESPACELIST  <<< "$NAMESPACE" 
read -ra LABELLIST <<< "$LABEL_SELECTOR"

echo NAMESPACELIST= $NAMESPACELIST
echo LABELLIST= $LABELLIST
i=100
for currentNAMESPACE in "${NAMESPACELIST[@]}"; do  
  for currentLABEL in "${LABELLIST[@]}"; do
    echo currentNAMESPACE=$currentNAMESPACE
    echo currentLABEL=$currentLABEL
    SRC_ADDR_GROUP=$(echo $currentNAMESPACE$currentLABEL | sed 's/[^A-Za-z]//g')
    echo src_addr_group $SRC_ADDR_GROUP
    echo currentNAMESPACE=$currentNAMESPACE
    echo currentLABEL=$currentLABEL
    POD_IPS=$(getPodNet1Ips $currentNAMESPACE  $currentLABEL)
    echo $POD_IPS
    i=$((i+1))
    policyid="$i"
    policyname="corptraffic$i"
    echo policyid=$policyid
    echo policyname=$policyname
    getCfosPodIp
    updateCfos
    createcfosfirewallpolicyifnogatekeeperpolicyexist   
  done
done 

 if [[ -z $POD_IPS ]]; then 
 echo "no ip exist "
 else
 #getCfosPodIp
 #updateCfos
 #createcfosfirewallpolicyifnogatekeeperpolicyexist
 echo "do nothing here"
 fi



for currentNAMESPACE in "${NAMESPACELIST[@]}"; do
  for currentLABEL in "${LABELLIST[@]}"; do
     SRC_ADDR_GROUP=$(echo $currentNAMESPACE$currentLABEL | sed 's/[^A-Za-z]//g')
    watchPodandUpdateCfosFirwallAddressGrpforSelectedNamespaceandLabel1 "$currentNAMESPACE $currentLABEL" &
  done
done


restartcfosifnodenumberchanaged &
wait

EOF
```
