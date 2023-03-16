- ## git clone the code

```
git clone https://github.com/yagosys/202301.git

```

- ## modify linux.auto.tfvars 

*cni can choose "calico" or "flannel"*
*when cni="calico", multus will be installed even multuscni="false"*
*you need to create cfos license file and assign name to cfoslicense*
*you need to generate your ssh key which will associate with each kubernetes node*
*you need to create a secret file for download cfos image for private repository*
*select instancetype that match your image architecture*

```
region="us-east-1"
instance_type="t3.large"
worker_count=2
#cni="calico"
cni="do not install"
multuscni="false"
gatekeeper="false"
cfosLicense="/home/i/fos_license.yaml"
key_location="~/.ssh/id_ed25519cfoslab"
dockerinterbeing="/home/i/dockerinterbeing.yaml"
```

*the deployment is based on terraform file, the terraform will deploy ec2 instance for k8s master  and k8s worker nodes*
*the k8s installed directly on ec2 instance  with kubeadm. the ubuntu is 22.04*
*when worker_count=0, master node can be used to create workload*
*only one master node will be created*

- ## deploy 

```
cd ./deployment/k8s
terraform apply
```
 