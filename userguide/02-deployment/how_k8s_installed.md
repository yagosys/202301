- ## k8s installation  
*k8s installed by use kubeadm, terraform use file user-data-for_master_node.tftpl to do the installation on master node  and use file user-data-for_worker_node.tftpl t odo the installation for workernode*

- ### linux version 
linux -AMD64
-  ubuntu 22.04
-  swap off

- ### images versions 

```
docker.io/flannel/flannel-cni-plugin       v1.1.2              7a2dcab94698c       8.25MB
docker.io/flannel/flannel                  v0.21.2             7b7f3acab868d       65.1MB
docker.io/interbeing/multus-cni            stable              c0e8690ae66a1       218MB
ghcr.io/k8snetworkplumbingwg/whereabouts   latest-amd64        04947e822536d       102MB
registry.k8s.io/coredns/coredns            v1.9.3              5185b96f0becf       48.9MB
registry.k8s.io/etcd                       3.5.6-0             fce326961ae2d       301MB
registry.k8s.io/kube-apiserver             v1.26.1             deb04688c4a35       135MB
registry.k8s.io/kube-controller-manager    v1.26.1             e9c08e11b07f6       125MB
registry.k8s.io/kube-proxy                 v1.26.1             46a6bb3c77ce0       67.2MB
registry.k8s.io/kube-scheduler             v1.26.1             655493523f607       57.7MB
registry.k8s.io/pause                      3.6                 6270bb605e12e       690kB
registry.k8s.io/pause                      3.9                 e6f1816883972       750kB
```

- ### tools installed 
```
- linux-modules-extra
- cri-o cri-o-runc cri-tools
- containernetworking-plugins 
- apt-transport-https ca-certificates
- nfs server
- kubelet
- kubectl
- kubeadm 
- jq 
```
- ### kernel moduels 

```
- overlay
- br_netfilter
```

- ### sysctl.conf  
```
- net.bridge.bridge-nf-call-iptables  = 1
- net.bridge.bridge-nf-call-ip6tables = 1
- net.ipv4.ip_forward                 = 1
```




**special notes:**

*due to some region image download is slow. therefore. the script will use crictl pull to download image before start deploy the yaml file that use image*

for example 
```
sudo crictl pull ghcr.io/k8snetworkplumbingwg/multus-cni:stable  
```

* the terraform installation log has redirected to the cloud console. access ec2 instance console will able to see it*
*meanwhile, the installation log also saved to file /var/log/user-data.log*

*the kuberadm generate a token that will not expire. so workernode can always use this token to join master*
*if you do not want a never expired token (--token-ttl-0) , you can change it in kubeadm init command*

```
sudo kubeadm init --cri-socket=unix:///var/run/crio/crio.sock --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --service-cidr=$SERVICE_CIDR --pod-network-cidr=$POD_CIDR --node-name $NODENAME  --token-ttl=0 -v=5  
```

*the kubeAPI is listen on default port ec2 instance private IP:6443 port. the kubectl client config is under ~/.kube/config*
*you have to ssh into master node to access the cluster API*



