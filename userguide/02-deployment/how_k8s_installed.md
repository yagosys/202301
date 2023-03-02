k8s installation  
the EC2 instance use file user-data-for_master_node.tftpl to do the installation for master node  
the EC2 instance use file user-data-for_worker_node.tftpl t odo the installation for workernode.  

linux   
-  ubuntu 22.04
-  swap off


tool installed

- linux-modules-extra
- cri-o cri-o-runc cri-tools
- containernetworking-plugins 
- apt-transport-https ca-certificates
- kubelet
- kubectl
- kubeadm 

kernel modules   

- vrf
- overlay
- br_netfilter

sysctl.conf  

- net.bridge.bridge-nf-call-iptables  = 1
- net.bridge.bridge-nf-call-ip6tables = 1
- net.ipv4.ip_forward                 = 1
- net.ipv4.conf.all.accept_redirects  = 0
- net.ipv4.conf.default.accept_redirects = 0

kubernetes cni  
- whereabouts
- multus 
- flannel (when workernode>0)


*special notes:*  

1. the kubernetes repository pubic key is diffcult to download in some region. it often fail. therefore. a local copy of GPG key is in the git repository. the GPG will be used as public key. if you want directly fetch GPG key from original place , you can change the tftpl  file 
from 
```
sudo cp /home/ubuntu/202301/deployment/k8s/kubernetes-archive-keyring.gpg /etc/apt/keyrings/kubernetes-archive-keyring.gpg

```
to 
```
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/keyrings/kubernetes-archive-keyring.gpg

```


2. due to some region image download is slow. therefore. the script will use crictl pull to download image before start deploy the yaml file that use image.   

for example 
```
sudo crictl pull ghcr.io/k8snetworkplumbingwg/multus-cni:stable  
```

3. the terraform installation log has redirected to the cloud console. access ec2 instance console will able to see it.
meanwhile, the installation log also saved to file /var/log/user-data.log   

4. the kuberadm generate a token that will not expire. so workernode can always use this token to join master. 
if you do not want a never expired token (--token-ttl-0) , you can change it in kubeadm init command.  
```
sudo kubeadm init --cri-socket=unix:///var/run/crio/crio.sock --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --service-cidr=$SERVICE_CIDR --pod-network-cidr=$POD_CIDR --node-name $NODENAME  --token-ttl=0 -v=5  
```
5. the kubeAPI is listen on default port ec2 instance private IP:6443 port. the kubectl client config is under ~/.kube/config 
you have to ssh into master node to access the cluster API.   


