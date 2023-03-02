the kubernetes default valus is defined in file   
variable.tf.   

```
vpc cidr : 10.0.0.0/16
master node subnet : 10.0.1.0/24
worker node subnet : 10.0.2.0/24
secritygroup: wild open. 
pod cidr : 10.244.0.0/16
service cidr : 10.96.0.0/12
clusterdnsip : 10.96.0.10

```
*if you change pod cidr from 10.244.0.0/16 to something else, then you will also need flannel configuration to match it. this is not included in the script*  

*please be aware the CNI do not always honor the pod CIDR.it often has it's own POD CIDR, for example, the bridge CNI has default 10.85.0.0/16, the flannel has 10.244.0.0/16 regardless cluster level podcidr setup.*  



