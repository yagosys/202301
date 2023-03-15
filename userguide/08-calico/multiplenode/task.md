- ## install calico

*this section will install tigera operator to install other calico crd, then install cr(customer resource), we also modify cr with necessary change such as cidr etc*

The Calico Tigera Operator is a Kubernetes operator designed to simplify the installation and management of the Calico networking and network policy solution on Kubernetes clusters. Calico is an open-source networking and network policy solution for Kubernetes and other cloud-native platforms.

The Calico Tigera Operator automates the deployment of Calico on Kubernetes, which can be complex and time-consuming to do manually. The operator uses a declarative configuration model, which allows you to define the desired state of your Calico deployment, and the operator will ensure that the actual state matches the desired state.

`calictl` is a command-line tool that allows you to interact with Calico to manage networking and network security policies on a Kubernetes cluster. this is optional. but will be useful for throubleshooting. 

Custom resources are extensions to the Kubernetes API that allow you to define and use resources beyond the built-in resources that come with Kubernetes. Calico uses custom resources to provide additional functionality beyond what is available with standard Kubernetes resources.

We need to modify Custom resources to enable **containerIPForwarding** and also change **podCIDR** to match cluster podCIDR configuration. 

for detail about Custom resources spec. use `kubectl explain Installation.spec`. 


```
sudo curl -fL https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o /usr/local/bin/calicoctl
sudo chmod +x /usr/local/bin/calicoctl
curl -fLO https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
kubectl create -f tigera-operator.yaml
curl -fLO https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

cat << EOF | kubectl create -f - 
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    bgp: Disabled
    containerIPForwarding: Enabled
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 24
      cidr: 10.244.0.0/16
      encapsulation: VXLAN
      natOutgoing: Enabled
      nodeSelector: all()
---

# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF 

```

- ### check calico installation 

use `kubectl get node -o json | jq .items[].metadata.annotations` to check the annotations added by calico , you can find podCIDR for each node.

use `kubectl get installation default -o yaml` to check the Custome resources installed by calico 

use `kubectl get all -n calico-system` to check calico resources is up and running 

use `kubectl get all -n calico-apiserver` to check api server is up and running 

use `sudo calicoctl node status` to check the  calico status and networking 

- ## install  multus 
*this section install multus cni but will not config to use multus as the default cni yet before we create multus crd*

Multus CNI is a Container Network Interface (CNI) plugin for Kubernetes that allows multiple network interfaces to be attached to a Kubernetes pod. This means that a pod can have multiple network interfaces, each with its own IP address, and can communicate with different networks simultaneously. 

When installing Multus CNI for Kubernetes, the multus-conf-file parameter by default set with the value "auto" which  means that Multus will automatically detect the configuration file to use.
The configuration file specifies how Multus CNI should operate and which network interfaces should be created for the pods. By default, Multus looks for a configuration file in the directory /etc/cni/net.d/ and uses the first configuration file it finds. If no configuration file is found, Multus uses a default configuration. 

We can config cni for Multus to use manually, so we change the **"auto" to 70-multus.conf**. the 70-multus.conf often will not become the first CNI for kubernetes if you already have installed calico or flannel etc other CNI. By default, the 70-multus.conf file includes bridge , loopback CNI, we do not need that.  

we can manually pull multu-cni installation package beforehand if you have a slow network or we can directly clone it from internent and install it with kubectl 

```
sudo crictl pull ghcr.io/k8snetworkplumbingwg/multus-cni:stable
cd /home/ubuntu
git clone https://github.com/intel/multus-cni.git
sudo sed -i 's/multus-conf-file=auto/multus-conf-file=\/tmp\/multus-conf\/70-multus.conf/g' /home/ubuntu/multus-cni/deployments/multus-daemonset.yml
cat /home/ubuntu/multus-cni/deployments/multus-daemonset.yml | kubectl apply -f -
```
- ### check the multus installation 

```
ubuntu@ip-10-0-1-100:~$ kubectl get ds kube-multus-ds -n kube-system
NAME             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-multus-ds   3         3         3       3            3           <none>          26m
ubuntu@ip-10-0-1-100:~$ kubectl logs ds/kube-multus-ds -n kube-system
Found 3 pods, using pod/kube-multus-ds-gjl4g
Defaulted container "kube-multus" out of: kube-multus, install-multus-binary (init)
2023-03-14T01:34:22+00:00 Entering sleep (success)...

```

- ### check cni configuration 
the default directory for cni config is under /etc/cni/net.d. 
```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ ls
10-calico.conflist  200-loopback.conf  70-multus.conf  calico-kubeconfig  multus.d  whereabouts.d
```
the file with extension name **.conf** or **.conflist** will be parsed by crio. 
The file with the highest priority for the CRI-O runtime is the one with the lowest alphabetically prefix in its filename. In this case, the file with the highest priority would be "10-calico.conflist".

The alphabetically prefix in the filename is used by CNI plugins to determine the order in which the plugin configurations are applied. A lower alphabetically prefix indicates higher priority, and hence, the configuration in the file with the lowest alphabetically prefix (in this case, 10) will be applied first, followed by the configuration in the file with the next lowest alphabetically prefix, and so on.

the ".conf" file extension is used for a single CNI plugin configuration file, while the ".conflist" file extension is used for a list of CNI plugin configurations.

the 10-calico.conf has name "k8s-pod-network" 
```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ cat 10-calico.conflist  | grep name
  "name": "k8s-pod-network",
```
since 10-calico.conflist has highest priority. so it shall be picked up by crio. so although multus has installed. but the default cni for kubernetes is still the calico. 

you can check crio log to confirm this 

``` 
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ journalctl -u crio  | grep "Updated default CNI network name to "  | tail -n 1
Mar 14 01:34:22 ip-10-0-1-100 crio[1675]: time="2023-03-14 01:34:22.467251630Z" level=info msg="Updated default CNI network name to k8s-pod-network"
ubuntu@ip-10-0-1-100:/etc/cni/net.d$

```

- ### create multus configuration and make multus become the default CNI for crio
*this section we  create multus cni config as the default cni also config it to delegate to multus crd object, the crd object will reference to json cni config on each of the node*

we need create two configuration that related with multus, first we need to create a multus crd with cni json config on each node  for multus cni  to delegates with. then we create multus cni config for crio to use it as the default cni .  after done these ,the order of cni operation for crio will become 

**pod request ---> k8s API--- crio --- multus cni ---- multu-crd with calico json config on each node**

first  we create net-calico.conf with name net-calico and place it under /etc/cni/multus/netd.conf/ , this config file will be read by multus crd. 
then we create multus crd to use net-calico.conf on each node. multus crd use key name to reference net-calico.conf on each node
finally, we create 00-multus.conf under /etc/cni/net.d for crio to pick as the default cni for kubernetes.


- ### create directory /etc/cni/multus/net.d  on each node 

this is the default directory for multus to fetch configuration. multus ds read config from this directory  automatically , there is no need to restart ds or do other config. 
first we need to create directory , by default, the directory is not exist. since crio is running on each node. so we need to do this on all nodes.

```
for node in 10.0.2.200 10.0.2.201 10.0.1.100; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@$node  sudo mkdir -p /etc/cni/multus/net.d
done
```

- ### create multus crd object  on master node
**the name is net-calico** 
```
cat << EOF | kubectl apply -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: net-calico
  namespace: kube-system
EOF
```

- ### create net-calico cni config under /etc/cni/multus/net.d on each worker node 
the net-calico.conf has name **"net-calico"** which match the crd net-attach-def (NetworkAttachmentDefinition) name, we also config to use host-local ipam and config different subnet range for pods on each node.  

```
nodes=("10.0.1.100" "10.0.2.200" "10.0.2.201")
cidr=("10.244.6" "10.244.97" "10.244.93")
for i in "${!nodes[@]}"; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@"${nodes[$i]}" << EOF 
cat << INNEREOF | sudo tee /etc/cni/multus/net.d/net-calico.conf
{
  "cniVersion": "0.3.1",
  "name": "net-calico",
  "type": "calico",
  "datastore_type": "kubernetes",
  "mtu": 0,
  "nodename_file_optional": false,
  "log_level": "Info",
  "log_file_path": "/var/log/calico/cni/cni.log",
  "ipam": {
    "type": "host-local",
    "ranges": [
       [
         {
           "subnet": "${cidr[$i]}.0/24",
           "rangeStart": "${cidr[$i]}.150",
           "rangeEnd": "${cidr[$i]}.250"
         }
       ]
    ]
  },
  "container_settings": {
      "allow_ip_forwarding": true
  },
  "policy": {
      "type": "k8s"
  },
  "kubernetes": {
      "k8s_api_root":"https://10.96.0.1:443",
      "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
  }
}
INNEREOF
EOF 
done
```

- ### create 00-multus.conf under /etc/cni/net.d on each node 

00-multus.conf has the lowest alphabetically order, so it will become the first CNI for crio. after create this file. the kubernetes cluster will not longer use 10-calico.conf 

we need to  create 00-multus.conf on each node. multus delegates to other cni based on multus crd config.

in 00-multus.conf ,  "clusterNetwork" and "defaultNetworks" fields are used to define the networking configuration for Kubernetes pods.

The "clusterNetwork" field specifies the name of the network that Kubernetes uses for internal cluster communication. This network is typically used for Kubernetes services, which provide a stable IP address and DNS name for accessing pods. The value of this field must match the name of a network plugin that has been installed on the cluster, such as net-calico 

The "defaultNetworks" field is used to specify a list of additional network plugins that should be used for the default network configuration of pods. When a pod is created, it will automatically be assigned one of these networks as its primary network. This allows pods to be connected to multiple networks simultaneously.

since we do not want add additional network for all pod in this cluster automatically. we do not config "defaultNetworks".  but just config **"clusterNetwork"** as pod in this cluster will need to have a clsuter network. 

this cni config has name **"multus-cni-network"**

if we run into issue . we can change logLevel to debug for more verbose information.

```
for node in 10.0.2.200 10.0.2.201 10.0.1.100; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@$node << EOF
cat << INNER_EOF | sudo tee /etc/cni/net.d/00-multus.conf
{
  "name": "multus-cni-network",
  "type": "multus",
  "confDir": "/etc/cni/multus/net.d",
  "cniDir": "/var/lib/cni/multus",
  "binDir": "/opt/cni/bin",
  "logFile": "/var/log/multus.log",
  "logLevel": "info",
  "capabilities": {
    "portMappings": true
  },
  "clusterNetwork": "net-calico",
  "defaultNetworks": [],
  "delegates": [],
  "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig"
}
INNER_EOF
EOF
done
``` 

- ### check crio log on each node

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ journalctl -f -u crio | grep 'Updated default CNI network name'
Mar 13 02:46:54 ip-10-0-1-100 crio[2449]: time="2023-03-13 02:46:54.059049524Z" level=info msg="Updated default CNI network name to multus-cni-network"
Mar 13 02:46:54 ip-10-0-1-100 crio[2449]: time="2023-03-13 02:46:54.132076903Z" level=info msg="Updated default CNI network name to multus-cni-network"
```

- ### verify multus now delegates to net-calico cni for default cluster network 
we can create a deployment without using any annotations to check whether default cluster newtork works.
below you will see that pod get network from kube-system/net-calico
```
kubectl create deployment normal --image=praqma/network-multitool --replicas=3

ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get pod
NAME                      READY   STATUS    RESTARTS   AGE
normal-6965c788cf-8vqjh   1/1     Running   0          4m33s
normal-6965c788cf-c9xb6   1/1     Running   0          4m33s
normal-6965c788cf-kwpqg   1/1     Running   0          4m33s
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl events --for pod/normal-6965c788cf-8vqjh
LAST SEEN   TYPE     REASON           OBJECT                        MESSAGE
4m46s       Normal   Scheduled        Pod/normal-6965c788cf-8vqjh   Successfully assigned default/normal-6965c788cf-8vqjh to ip1001100
4m45s       Normal   AddedInterface   Pod/normal-6965c788cf-8vqjh   Add eth0 [10.244.6.150/32] from kube-system/net-calico
4m45s       Normal   Pulling          Pod/normal-6965c788cf-8vqjh   Pulling image "praqma/network-multitool"
4m37s       Normal   Pulled           Pod/normal-6965c788cf-8vqjh   Successfully pulled image "praqma/network-multitool" in 7.813389351s (7.813395276s including waiting)
4m37s       Normal   Created          Pod/normal-6965c788cf-8vqjh   Created container network-multitool
4m37s       Normal   Started          Pod/normal-6965c788cf-8vqjh   Started container network-multitool
```


- ###  create network "default-calico" under /etc/cni/multus/net.d on each node 

create default-calico multus crd with cni config under /etc/cni/multus/net.d on each node with different pod ip address range  for application that want to route traffic to cfos 

this step is **optional**, POD can directly use net-calico crd for default networking. here we just show that we can create multiple default cluster network. and let application to choose which default network. with this approach. we need keep original pod/cluster configuration not impacted at all. only those application that want route traffic to cfos will using new default network based on the annotations.

we do not want a default route from this network. so we remove the default route from this cni configuration below,but we added two specif route.

the crd has name "default-calico" and the cni config on each node has same name but with different PODCIDR address.

```
cat << EOF | kubectl apply -f - 
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: default-calico
  namespace: kube-system
EOF 

```
*default-calico cni under /etc/cni/multus/net.d on each node*

```

nodes=("10.0.1.100" "10.0.2.200" "10.0.2.201")
cidr=("10.244.6" "10.244.97" "10.244.93")
for i in "${!nodes[@]}"; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@"${nodes[$i]}" << EOF
cat << INNEREOF | sudo tee /etc/cni/multus/net.d/default-calico.conf.bak
{
  "cniVersion": "0.3.1",
  "name": "default-calico",
  "type": "calico",
  "datastore_type": "kubernetes",
  "mtu": 0,
  "nodename_file_optional": false,
  "log_level": "Info",
  "log_file_path": "/var/log/calico/cni/cni.log",
  "ipam": {
    "type": "host-local",
    "ranges": [
       [
         {
           "subnet": "${cidr[$i]}.0/24", 
           "rangeStart": "${cidr[$i]}.50",
           "rangeEnd": "${cidr[$i]}.100"
         }
       ]
    ],
   "routes": [
      { "dst": "10.96.0.0/12" },
      { "dst": "10.0.0.0/8" }
   ]
  },
  "container_settings": {
      "allow_ip_forwarding": true
  },
  "policy": {
      "type": "k8s"
  },
  "kubernetes": {
      "k8s_api_root":"https://10.96.0.1:443",
      "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
  }
}
INNEREOF
EOF 
done

```

- ## show how POD can attach to different network 
*this section we show how to create a pod use default cluster-network, then use annotations to change the default network and then use annotations to add additional network*

- ###  creaete a pod attach to  default cluster network to net-calico 

we create an deployment without using annotations. then POD will be assigned with default cluster network configuration by multus. which is net-calico. 
the net-calico do not have any confiugration about route entry. so POD in this network will have default route . which is 169.254.1.1 for calico CNI.

```
kubectl create deployment normal --image=praqma/network-multitool --replicas=3
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/normal-6965c788cf-s2r2h -- ip r
default via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
```
- ### use annotations to change pod's default network to default-calico 

*we use kubectl patch to config deployment with new network "default-calico" by add annotations to metadata field, this network have removed default route for pod*

```
kubectl patch deployment normal  -p '{"spec": {"template":{"metadata":{"annotations":{"v1.multus-cni.io/default-network":"[{\"name\": \"default-calico\"}]"}}}}}'
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/normal-7cd6974c5c-t4hfq -- sh
/ # ip r
10.0.0.0/8 via 169.254.1.1 dev eth0
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
kubectl describe po/normal-7cd6974c5c-t4hfq
...
Name:             normal-7cd6974c5c-t4hfq
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip1001100/10.0.1.100
Start Time:       Mon, 13 Mar 2023 00:18:08 +0000
Labels:           app=normal
                  pod-template-hash=7cd6974c5c
Annotations:      cni.projectcalico.org/containerID: 62d6132c27c7a648ed2a7e9b453969f470b3928232ce9e0059092021bc436bf9
                  cni.projectcalico.org/podIP: 10.244.6.51/32
                  cni.projectcalico.org/podIPs: 10.244.6.51/32
                  k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "kube-system/default-calico",
                        "ips": [
                            "10.244.6.51"
                        ],
                        "default": true,
                        "dns": {}
                    }]
                  k8s.v1.cni.cncf.io/networks-status:
                    [{
                        "name": "kube-system/default-calico",
                        "ips": [
                            "10.244.6.51"
                        ],
                        "default": true,
                        "dns": {}
                    }]
                  v1.multus-cni.io/default-network: [{"name": "default-calico"}]
Status:           Running
IP:               10.244.6.51
...

```


- ### create multus secondary network crd  with bridge cni json config  


```
echo 'do this on master node'
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
      "ipMasq": false,
      "hairpinMode": true,
      "ipam": {
          "type": "host-local",
          "routes": [
              { "dst": "10.96.0.0/12","gw": "10.1.128.1" },
              { "dst": "10.0.0.2/32", "gw": "10.1.128.1" }
          ],
          "ranges": [
              [{ "subnet": "10.1.128.0/24" }]
          ]
      }
    }
EOF 

```
- ### patch normal deployment to use secondary bridge network and add a default route 

```
kubectl patch deployment normal -p '{"spec": {"template":{"metadata":{"annotations":{"k8s.v1.cni.cncf.io/networks":"[{\"name\": \"cfosdefaultcni5\", \"default-route\": [\"10.1.128.2\"]}]"}}}}}'

```
you will see the pod now has a default route point to secondary network which is 10.1.128.2 via net1 interface.
```
ubuntu@ip-10-0-1-100:/etc/cni/multus/net.d$ kubectl exec -it po/normal-58945bc79d-4j9zb -- sh
/ # ip r
default via 10.1.128.2 dev net1
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.2
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default
    link/ether 4e:bd:4d:48:4d:20 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.6.51/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::4cbd:4dff:fe48:4d20/64 scope link
       valid_lft forever preferred_lft forever
4: net1@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 0e:72:39:68:6d:ee brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.128.2/24 brd 10.1.128.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::c72:39ff:fe68:6dee/64 scope link
       valid_lft forever preferred_lft forever
# ip r
default via 10.1.128.2 dev net1
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.2
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link

```

- ## calico network explained


*this section we explain how calico network works,the key is calico use proxy arp with a pesudo gateway 169.254.1.1*

calico network configuraition can be checked with
```
ubuntu@ip-10-0-2-200:~$ kubectl get installation default -o jsonpath={.spec.calicoNetwork}
{"bgp":"Disabled","containerIPForwarding":"Enabled","hostPorts":"Enabled","ipPools":[{"blockSize":24,"cidr":"10.244.0.0/16","disableBGPExport":false,"encapsulation":"VXLAN","natOutgoing":"Enabled","nodeSelector":"all()"}],"linuxDataplane":"Iptables","multiInterfaceMode":"None","nodeAddressAutodetectionV4":{"firstFound":true}}ubuntu@ip-10-0-2-200:~$ kubectl get installation default -o jsonpath={.spec.calicoNetwork} | jq .
{
  "bgp": "Disabled",
  "containerIPForwarding": "Enabled",
  "hostPorts": "Enabled",
  "ipPools": [
    {
      "blockSize": 24,
      "cidr": "10.244.0.0/16",
      "disableBGPExport": false,
      "encapsulation": "VXLAN",
      "natOutgoing": "Enabled",
      "nodeSelector": "all()"
    }
  ],
  "linuxDataplane": "Iptables",
  "multiInterfaceMode": "None",
  "nodeAddressAutodetectionV4": {
    "firstFound": true
  }
}
```

- ### walkthrough each hop from source pod to destination pod on other node 

```
ubuntu@ip-10-0-2-200:~$ kubectl get pod -o wide
NAME                                    READY   STATUS    RESTARTS   AGE    IP             NODE            NOMINATED NODE   READINESS GATES
multitool01-deployment-bb4c98bb-8p4lt   1/1     Running   0          155m   10.244.97.51   ip-10-0-2-200   <none>           <none>
multitool01-deployment-bb4c98bb-flspr   1/1     Running   0          155m   10.244.93.50   ip-10-0-2-201   <none>           <none>
```
above we have two pod in two nodes. they are in different subnets. we can check on each hop with tcpdump etc tool.


-###### **(src pod:10.244.97.51)---[(cali-)-(10.244.97.0/32)-ens5-(10-0.2.200)]-vpc-subnet-[(10.0.2.201)-ens5-vxlan.calico-(10.244.93.0/32)-(cali)]--(dst pod:10.244.93.50)** ######

from pod eth0 interface 10.244.97.51 to pod 10.244.93.50

- #### step1: ip route lookup found the nexthop is 169.254.1.1

this ip address is not on any interface. caclico hardcoded this ip address. so the arp request for this address will happen routing happens.

``` 
ubuntu@ip-10-0-2-200:~$ kubectl exec -it po/multitool01-deployment-bb4c98bb-8p4lt -- ip route get 10.244.93.50
10.244.93.50 via 169.254.1.1 dev eth0 src 10.244.97.51 uid 0
    cache
```

- #### step2: send arp request for 169.254.1.1 got reply with mac address: ee:ee:ee:ee:ee:ee 
when source pod do l3 forwarding. the arp request to 169.254.1.1 will be generated. this arp request will reach host interface via veth pair.(pod3: host:if13)
pod is connecting with host interface (index13 : cali6d544638a21@if3). 
```
ubuntu@ip-10-0-2-200:~$ kubectl exec -it po/multitool01-deployment-bb4c98bb-8p4lt -- ip a  | grep eth0
3: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default
    inet 10.244.97.51/32 scope global eth0

ubuntu@ip-10-0-2-200:~$ kubectl exec -it po/multitool01-deployment-bb4c98bb-8p4lt -- ping 10.244.93.50

ubuntu@ip-10-0-2-200:~$ kubectl exec -it po/multitool01-deployment-bb4c98bb-8p4lt -- sh 
ubuntu@ip-10-0-2-200:~$ sudo tcpdump -i cali6d544638a21 arp
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on cali6d544638a21, link-type EN10MB (Ethernet), snapshot length 262144 bytes
06:16:47.733555 ARP, Request who-has 169.254.1.1 tell 10.244.97.51, length 28
06:16:47.733635 ARP, Reply 169.254.1.1 is-at ee:ee:ee:ee:ee:ee (oui Unknown), length 28

```

- #### step3: this arp request reached host interface cali6d544638a21, this cali interface replied the arp request with mac ee:ee:ee:ee:ee:ee 
```
ubuntu@ip-10-0-2-200:~$ sudo tcpdump -i cali6d544638a21  -n
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on cali6d544638a21, link-type EN10MB (Ethernet), snapshot length 262144 bytes
05:36:54.101773 ARP, Request who-has 169.254.1.1 tell 10.244.97.51, length 28
05:36:54.101784 ARP, Reply 169.254.1.1 is-at ee:ee:ee:ee:ee:ee, length 28
``` 
this is because the interface cali6d544638a21 on host has **proxy arp** enabled. this interface does not have ip address. but will response arp request with it's macddress

```
ubuntu@ip-10-0-2-200:~$ cat /proc/sys/net/ipv4/conf/cali6d544638a21/proxy_arp
1
```

- #### step4: source pod use ee:ee:ee:ee:ee:ee as dst mac send traffic to host. 
- #### step5: host do route lookup for dst 10.244.93.50 found nexthop is 10.244.93.0 which is vxlan.calico interface , normal vxlan tunnel follows. 
```
ubuntu@ip-10-0-2-200:~$ ip r get 10.244.93.50
10.244.93.50 via 10.244.93.0 dev vxlan.calico src 10.244.97.0 uid 1000
    cache
``` 
on this host, the nexthop ip address 10.244.93.0 has a permant mac address. so traffic will reach tunnel interface.   
```
ubuntu@ip-10-0-2-200:~$ ip route | grep 10.244.93.0
10.244.93.0/24 via 10.244.93.0 dev vxlan.calico onlink
ubuntu@ip-10-0-2-200:~$ ip neighbor | grep 10.244.93.0
10.244.93.0 dev vxlan.calico lladdr 66:73:5c:ce:0d:ae PERMANENT
```
- #### step6: vxlan.calico interface encapsulate packet with vxlan and send via ens5 interface to peer node. 
you can see, by default, vxlan.calico interface use vlxan id 4096 and dst port is 4789. nolearning is configured, so no mac will be learned on this interface  
```
ubuntu@ip-10-0-2-200:~$ ip -d address show dev vxlan.calico
5: vxlan.calico: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UNKNOWN group default
    link/ether 66:55:b7:b7:f8:dc brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 68 maxmtu 65535
    vxlan id 4096 local 10.0.2.200 dev ens5 srcport 0 0 dstport 4789 nolearning ttl auto ageing 300 udpcsum noudp6zerocsumtx noudp6zerocsumrx numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
    inet 10.244.97.0/32 scope global vxlan.calico
       valid_lft forever preferred_lft forever
    inet6 fe80::6455:b7ff:feb7:f8dc/64 scope link
       valid_lft forever preferred_lft forever

ubuntu@ip-10-0-2-200:~$ sudo tcpdump -i vxlan.calico -n -vvv src 10.244.97.51
tcpdump: listening on vxlan.calico, link-type EN10MB (Ethernet), snapshot length 262144 bytes
05:50:40.481791 IP (tos 0x0, ttl 63, id 19904, offset 0, flags [DF], proto ICMP (1), length 84)
    10.244.97.51 > 10.244.93.50: ICMP echo request, id 60, seq 134, length 64
05:50:41.505776 IP (tos 0x0, ttl 63, id 20114, offset 0, flags [DF], proto ICMP (1), length 84)
    10.244.97.51 > 10.244.93.50: ICMP echo request, id 60, seq 135, length 64
```
- #### step 7 ens5 interface send vxlan packet to destination, packet reach destination pod. reverse procedure will happen for icmp reply. 
```
ubuntu@ip-10-0-2-200:~$ sudo tcpdump -i ens5 -n udp  port 4789 && src 10.0.2.200
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on ens5, link-type EN10MB (Ethernet), snapshot length 262144 bytes
05:55:35.201797 IP 10.0.2.200.45547 > 10.0.2.201.4789: VXLAN, flags [I] (0x08), vni 4096
IP 10.244.97.51 > 10.244.93.50: ICMP echo request, id 60, seq 422, length 64
05:55:35.202047 IP 10.0.2.201.40770 > 10.0.2.200.4789: VXLAN, flags [I] (0x08), vni 4096
IP 10.244.93.50 > 10.244.97.51: ICMP echo reply, id 60, seq 422, length 64
```

