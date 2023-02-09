**preparation**
prepare terraform enviroment to deploy . for example ,in linux enviroment. install git, aws cli ,terraform and configure aws credential. 

**clone the repository**
```bash
git clone https://github.com/yagosys/202301.git
```
**deploy k8s on ubuntu22.04**
```
cd 202301/deployment/k8s/
```
**or deploy k8s on ubuntu20.04**
```
cd 202301/deployment/k8s2004
```

**deploy**
review auto.tfvars file and modify accordingly to meet the deployment requirement.

```bash
terraform apply -auto-approve
```

**once execute sucessfully** 
```bash
Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_public_ip = (known after apply)
aws_vpc.k8slab: Creating...
aws_vpc.k8slab: Creation complete after 2s [id=vpc-0c959941ee601fa49]
aws_internet_gateway.k8slab: Creating...
aws_subnet.k8slab: Creating...
aws_security_group.k8slab: Creating...
aws_internet_gateway.k8slab: Creation complete after 1s [id=igw-07c91b77e8741396c]
aws_route_table.k8slab: Creating...
aws_route_table.k8slab: Creation complete after 1s [id=rtb-0f71ac9e4b9083109]
aws_security_group.k8slab: Creation complete after 2s [id=sg-001c10d13a3ff9498]
aws_subnet.k8slab: Still creating... [10s elapsed]
aws_subnet.k8slab: Creation complete after 11s [id=subnet-0227c760f3e1ee12f]
aws_route_table_association.k8slab: Creating...
aws_instance.k8slab: Creating...
aws_route_table_association.k8slab: Creation complete after 0s [id=rtbassoc-0013bed3b32264b0e]
aws_instance.k8slab: Still creating... [10s elapsed]
aws_instance.k8slab: Provisioning with 'file'...
aws_instance.k8slab: Still creating... [20s elapsed]
aws_instance.k8slab: Creation complete after 25s [id=i-017cd36753c6c97cb]

aws_instance.k8slab (remote-exec): pod/fedora-net1-10-2-128 created
aws_instance.k8slab (remote-exec): + touch /home/ubuntu/deploymentcompleted
aws_instance.k8slab: Creation complete after 3m10s [id=i-0097d26c0c05b2cef]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

instance_public_ip = "52.221.244.192"
```

then shell into this vm use ssh  ubuntu@52.221.244.192 



ubuntu@ip-10-0-1-218:~$
```
**deploy east-west use case **

```
cd /home/ubuntu/202301/eastwest
kubectl apply -f 1_net_attach_10_1_128.yaml
kubectl apply -f 2_net_attach_10_2_128.yaml
kubectl apply -f 3_cfosdeployment.yaml
kubectl apply -f 4_fedora_pod_br-10-1-128.yaml
kubectl apply -f 5_fedora_pod_br-10-2-128.yaml
kubectl apply -f ./config/log_config.yaml
kubectl apply -f ./config/firewallpolicy.yaml
````

**shell into cfos**
```
ubuntu@ip-10-0-1-218:~/202301/eastwest$ kubectl exec -it po/fos-deployment-c7d8bf8d9-gxz77  -- sh
# fcnsh
FOS Container # diagnose  sys status
Version: cFOS v7.2.0 build0231
Serial-Number:
System time: Mon Feb 06 2023 08:14:36 GMT+0000 (UTC)
```

**check interface config and firewall policy config**

```
FOS Container (interface) # show

config system interface
    edit "eth0"
        set ip 10.85.0.8 255.255.0.0
        set macaddr 0a:9b:8f:83:34:78
        config ipv6
            set ip6-address fe80::89b:8fff:fe83:3478/64
        end
    next
    edit "net1"
        set ip 10.1.128.4 255.255.255.0
        set macaddr 22:02:bc:e1:6c:51
        config ipv6
            set ip6-address fe80::2002:bcff:fee1:6c51/64
        end
    next
    edit "net2"
        set ip 10.2.128.4 255.255.255.0
        set macaddr 02:53:29:87:21:35
        config ipv6
            set ip6-address fe80::53:29ff:fe87:2135/64
        end
    next
    edit "any"
    next
end
FOS Container (interface) # end

FOS Container # config firewall policy

FOS Container (policy) # show
config firewall policy

    edit "1"
        set utm-status enable
        set name "net1-net2-east-west"
        set srcintf net1
        set dstintf net2
        set srcaddr all
        set dstaddr all
        set service HTTP
        set ssl-ssh-profile "deep-inspection"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
    edit "2"
        set name "net1-net2-east-west-ping_noNAT"
        set srcintf net1
        set dstintf net2
        set srcaddr all
        set dstaddr all
        set service PING
        set logtraffic all
    next
    edit "3"
        set utm-status enable
        set name "pod_to_internet_HTTPS_HTTP"
        set srcintf any
        set dstintf eth0
        set srcaddr all
        set dstaddr all
        set service HTTPS HTTP
        set ssl-ssh-profile "deep-inspection"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
    edit "4"
        set name "tonginxclusterip"
        set srcintf net1
        set dstintf net2
        set srcaddr all
        set service HTTP
        set nat enable
        set logtraffic all
    next
end
FOS Container (policy) #
```
