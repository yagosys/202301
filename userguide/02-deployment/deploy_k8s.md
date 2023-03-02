- git clone the code

```
git clone https://github.com/yagosys/202301.git

```

the deployment is based on terraform file, the terraform will deploy ec2 instance for k8s master and ec2 instance for k8s worker node.

the k8s installed directly on ec2 instance  with kubeadm. the ubuntu is 22.04 .

navigate to directory 
./deployment/k8s

modify linux.auto.tfvars to meet your requirement

```
region="ap-southeast-1"
instance_type="t3.large"
worker_count=0
cfosLicense="/Users/ubuntu/fos_license.yaml"
key_location="~/.ssh/id_ed25519cfoslab"
dockerinterbeing="/Users/ubuntu/dockerinterbeing.yaml"
```

*notes:*  
*instance_type*  
select instancetype that match your image architecture.
*worker_count*  
number for k8s worker node, each worker node corresponding to one EC2 instance
if worker_count =0, then no worker_node will be installed, the master node will be used to create POD. also flannel will not be installed.

- deploy

```
cd ./deployment/k8s
terraform apply
```
