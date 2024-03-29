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

- ## install  multus with multus-conf-file set to manual  
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


- ## create multus secondary network crd  with bridge cni json config  


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
- ### delete normal deployment 

``` 
  kubectl delete deployment normal 

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


```
 (src pod:10.244.97.51)---[(cali-)-(vxlan.calico-10.244.97.0/32)-ens5-(10-0.2.200)]
                                                                   -vpc-subnet-[(10.0.2.0/24)
 (dst pod:10.244.93.50)---[(cali-)-(vxlan.calico-10.244.93.0/32)-ens5-(10.0.2.201)]

 ```

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



- ## use configmap to deploy cfos configuration 

```
cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cfosdata
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1.1Gi
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /home/ubuntu/data/pv0001
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cfosdata
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

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
  name: foscfgstaticdefaultroute
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config router static
       edit "1"
           set gateway 169.254.1.1
           set device "eth0"
       next
    end

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
kind: ConfigMap
metadata:
  name: foscfgdns
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config system dns
      set primary 10.96.0.10
      set secondary 10.0.0.2
    end

EOF

```


- ## deploy cfos daemonSet with new defaultNetwork and secondaryNetwork
*cfos use annotations to specify default-network to "default-calico, and additional network to cfosdefaultcni5 crd*

*cfos configured with static ip 10.1.128.252 on net1 interface*

*cfos expose 80 port which is restful interface via CLusterIP*

*cfos config linux capabilities ["NET_ADMIN","SYS_ADMIN","NET_RAW"] , NET_ADMIN and NET_RAW are required for use packet capture and ping*

*cfos configured with local storage on each node and mounted as /data folder*

*cfos do not config default route via default-calico or cfosdefaultcni5. instead , the default route is configured through cfos static route which install route not in main routing table but in table 231. table 231 has higher priority than main routing table*

*cfos congured as DaemonSet, so each node will have only one cfos POD, if more than 1 cfos POD is needed. config another DaemonSet for cFOS with different static IP*


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
        v1.multus-cni.io/default-network: default-calico
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.128.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
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
        #nfs:
        #  server: 10.0.1.100
        #  path: /home/ubuntu/data
        #  readOnly: no
        persistentVolumeClaim:
          claimName: cfosdata
EOF
```
- ### check cfos deployment 
*check the deployment*

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl rollout status ds/fos-deployment
daemon set "fos-deployment" successfully rolled out
```
*restart cfos ds*

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl rollout restart ds/fos-deployment
daemonset.apps/fos-deployment restarted
```
*chech the cfos pod log on pod on node 10-0-2-200*

you will found the cfos is running 7.2.0.0231 version and System is ready, also a few configmap has been read into cfos include license etc.,

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl logs -f po/`kubectl get pods -l app=fos --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`

System is starting...

Firmware version is 7.2.0.0231
Preparing environment...
RTNETLINK answers: File exists
Starting services...
System is ready.

2023-03-15_08:33:34.90495 ok: run: /run/fcn_service/certd: (pid 261) 0s, normally down
2023-03-15_08:33:39.93470 INFO: 2023/03/15 08:33:39 received a new fos configmap
2023-03-15_08:33:39.93471 INFO: 2023/03/15 08:33:39 configmap name: fos-license, labels: map[app:fos category:license]
2023-03-15_08:33:39.93471 INFO: 2023/03/15 08:33:39 got a fos license
2023-03-15_08:33:39.93474 INFO: 2023/03/15 08:33:39 received a new fos configmap
2023-03-15_08:33:39.93474 INFO: 2023/03/15 08:33:39 configmap name: foscfgdns, labels: map[app:fos category:config]
2023-03-15_08:33:39.93474 INFO: 2023/03/15 08:33:39 got a fos config
2023-03-15_08:33:39.93492 INFO: 2023/03/15 08:33:39 received a new fos configmap
2023-03-15_08:33:39.93493 INFO: 2023/03/15 08:33:39 configmap name: foscfgstaticdefaultroute, labels: map[app:fos category:config]
2023-03-15_08:33:39.93493 INFO: 2023/03/15 08:33:39 got a fos config
2023-03-15_08:33:39.93493 INFO: 2023/03/15 08:33:39 received a new fos configmap
2023-03-15_08:33:39.93494 INFO: 2023/03/15 08:33:39 configmap name: foscfgfirewallpolicy, labels: map[app:fos category:config]
2023-03-15_08:33:39.93494 INFO: 2023/03/15 08:33:39 got a fos config
```

- ### shell into cfos container 


```
ubuntu@ip-10-0-1-100:~/202301$ kubectl exec -it po/`kubectl get pods -l app=fos --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  -- sh
# ip route
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.252
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
```
cfos do not have default route on main routing table.  

```
# ip route show table 231
default via 169.254.1.1 dev eth0 metric 10
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.252
10.96.0.0/12 via 10.1.128.1 dev net1
169.254.1.1 dev eth0 scope link
```
but it has default route configured on route table 231. this is configured by cfos static route via configmap.

```
# fcnsh
FOS Container # config router static

FOS Container (static) # show
config router static
    edit "1"
        set gateway 169.254.1.1

        set device "eth0"
    next
end
FOS Container (static) #
```

so cfos container can reach internet, we can go back from cfos console via `sysctl sh` to container shell to do this

```

FOS Container # sysctl sh
# ip route get 1.1.1.1
1.1.1.1 via 169.254.1.1 dev eth0 table 231 src 10.244.97.53 uid 0
    cache
# ping -c 1 1.1.1.1
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: seq=0 ttl=48 time=1.753 ms

--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.753/1.753/1.753 ms
```
*check firewall policy configured on cfos*
```
FOS Container # config firewall policy

FOS Container (policy) # show
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
        set av-profile "default"
        set webfilter-profile "default"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
end
```
*check firewall policy by use cfos restful api*

*first let the cfos restful service is up and running in k8s, this is configured via ClusterIP.*


```
ubuntu@ip-10-0-1-100:~/202301$ kubectl get svc fos-deployment
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
fos-deployment   ClusterIP   10.100.57.107   <none>        80/TCP    19m

if you want use dns name to access fos-deployment svc , you need add dns 10.96.0.10 on your client.
10.96.0.10 is the kube-dns service ip address.

```
ubuntu@ip-10-0-1-100:~/202301$ cat << EOF | sudo tee -a /etc/resolv.conf
nameserver 10.96.0.10
nameserver 127.0.0.53
options edns0 trust-ad
search cluster.local ec2.internal
EOF
```
then you can use fos-deployment.default.svc.cluster.local to access fos restful api. 

```
ubuntu@ip-10-0-1-100:~/202301$ curl http://fos-deployment.default.svc.cluster.local
welcome to the REST API server`

```

ubuntu@ip-10-0-1-100:~/202301/opa/demo_network_policy_1$ curl http://10.100.57.107/api/v2/cmdb/firewall/policy
{
  "status": "success",
  "http_status": 200,
  "path": "firewall",
  "name": "policy",
  "http_method": "GET",
  "results": [
    {
      "policyid": "3",
      "status": "enable",
      "utm-status": "enable",
      "name": "pod_to_internet_HTTPS_HTTP",
      "comments": "",
      "srcintf": [
        {
          "name": "any"
        }
      ],
      "dstintf": [
        {
          "name": "eth0"
        }
      ],
      "srcaddr": [
        {
          "name": "all"
        }
      ],
      "dstaddr": [
        {
          "name": "all"
        }
      ],
      "srcaddr6": [],
      "dstaddr6": [],
      "service": [
        {
          "name": "HTTPS"
        },
        {
          "name": "HTTP"
        },
        {
          "name": "PING"
        },
        {
          "name": "DNS"
        }
      ],
      "ssl-ssh-profile": "deep-inspection",
      "profile-type": "single",
      "profile-group": "",
      "profile-protocol-options": "default",
      "av-profile": "default",
      "webfilter-profile": "default",
      "dnsfilter-profile": "",
      "emailfilter-profile": "",
      "dlp-sensor": "",
      "file-filter-profile": "",
      "ips-sensor": "default",
      "application-list": "",
      "action": "accept",
      "nat": "enable",
      "custom-log-fields": [],
      "logtraffic": "all"
    }
  ],
  "serial": "FGVMULTM23000044",
  "version": "v7.2.0",
  "build": "231"
```

- ### create demo application deployment  
*this application pod use default-network "default-calico", and also attached to secondary network "cfosdefaultcni5"*

*pod will obtain default route from "cfosdefaultcni5" by use annotations with key-workd k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.128.252"]  } ]'*

*we need use this pod to do tcpdump, ping  etc, so we assigned capabilities with "NET_ADMIN","SYS_ADMIN","NET_RAW"*

```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 3
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        v1.multus-cni.io/default-network: default-calico
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.128.252"]  } ]'
    spec:
      containers:
        - name: multitool01
          #image: wbitt/network-test
          image: praqma/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
          capabilities:
              add: ["NET_ADMIN","SYS_ADMIN","NET_RAW"]
          #  privileged: true
EOF
```

- ### check the application pod 

*application pod shall have default route point to cfos* 

*application pod shall have route to cluster via 169.254.1.1*


```
ubuntu@ip-10-0-1-100:~/202301/opa/demo_network_policy_1$ kubectl exec -it po/`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  -- sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default
    link/ether f2:da:87:c5:92:46 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.97.51/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f0da:87ff:fec5:9246/64 scope link
       valid_lft forever preferred_lft forever
4: net1@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ba:5a:93:d8:61:44 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.128.253/24 brd 10.1.128.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::b85a:93ff:fed8:6144/64 scope link
       valid_lft forever preferred_lft forever

/ # ip r
default via 10.1.128.252 dev net1
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.253
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
/ # ping -c 1 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=47 time=2.12 ms
--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.121/2.121/2.121/0.000 ms
/ # curl -I -k https://1.1.1.1
HTTP/2 200
date: Wed, 15 Mar 2023 09:03:22 GMT
content-type: text/html
report-to: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v3?s=tcg8Ecs%2FWjBOHrQkJ%2BTPCwJ4QBvxYTUPKElyCOe6DrqEfPDJBmnDIIdZ08j1gCQx9QsTV9Jn86nxwmW4wce2xmnDzapboa7IQGFqpY3bZZYhW7nDfvhXkRw%3D"}],"group":"cf-nel","max_age":604800}
nel: {"report_to":"cf-nel","max_age":604800}
last-modified: Thu, 04 Aug 2022 19:10:01 GMT
strict-transport-security: max-age=31536000
served-in-seconds: 0.003
cache-control: public, max-age=14400
cf-cache-status: HIT
age: 157
expires: Wed, 15 Mar 2023 13:03:22 GMT
set-cookie: __cf_bm=LguStn__XIFDst0ibfBMUsHgGuuQu.eOuD.WRLIMWV4-1678871002-0-Ae5GwkW8ybCBMgJ9M0xf2SpJP9IAx4EQDqKB9g9DI+o782XdLhJb93VsHoprs9azz4QkSge/Hpq414iP/dc0XbI=; path=/; expires=Wed, 15-Mar-23 09:33:22 GMT; domain=.every1dns.com; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 7a839535ddf53b0c-IAD
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400
```

*we can also do sniff on cfos for traffic from pod to internet*

*continue ping on application pod*

```
ubuntu@ip-10-0-1-100:~/202301/opa/demo_network_policy_1$ kubectl exec -it po/`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  -- ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=47 time=1.92 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=47 time=1.80 ms
```
*check cfos sniff* 

```
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/fos-deployment-8ssms -- sh
# fcnsh
FOS Container # diagnose sniffer packet any
interfaces=[any]
filters=[none]
count=unlimited
snaplen=1600

FOS Container # linktype = 113
0.874959 10.1.128.253 -> 1.1.1.1: icmp: echo request
0.875066 10.244.97.53 -> 1.1.1.1: icmp: echo request
0.876636 1.1.1.1 -> 10.244.97.53: icmp: echo reply
0.876707 1.1.1.1 -> 10.1.128.253: icmp: echo reply
1.876885 10.1.128.253 -> 1.1.1.1: icmp: echo request
1.877035 10.244.97.53 -> 1.1.1.1: icmp: echo request
1.878552 1.1.1.1 -> 10.244.97.53: icmp: echo reply
1.878634 1.1.1.1 -> 10.1.128.253: icmp: echo reply
1.940998 arp who-has 10.1.128.253 tell 10.1.128.252
1.941155 arp reply 10.1.128.253 is-at ba:5a:93:d8:61:44
2.878803 10.1.128.253 -> 1.1.1.1: icmp: echo request
2.878918 10.244.97.53 -> 1.1.1.1: icmp: echo request
2.880457 1.1.1.1 -> 10.244.97.53: icmp: echo reply
2.880509 1.1.1.1 -> 10.1.128.253: icmp: echo reply
3.880679 10.1.128.253 -> 1.1.1.1: icmp: echo request
3.880793 10.244.97.53 -> 1.1.1.1: icmp: echo request
3.882886 1.1.1.1 -> 10.244.97.53: icmp: echo reply
3.882974 1.1.1.1 -> 10.1.128.253: icmp: echo reply
```

*check cfos traffic log*

```
FOS Container # execute  log filter category traffic

FOS Container # execute log filter device disk

FOS Container # execute  log display
date=2023-03-15 time=08:32:04 eventtime=1678869124 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 srcport=53772 dstip=1.1.1.1 dstport=443 sessionid=1070264054 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:03:44 eventtime=1678871024 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=32 dstip=1.1.1.1 sessionid=912886433 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:05:47 eventtime=1678871147 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 srcport=58914 dstip=1.1.1.1 dstport=443 sessionid=507646218 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:09:45 eventtime=1678871385 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=35 dstip=1.1.1.1 sessionid=1935580230 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:10:46 eventtime=1678871446 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=41 dstip=1.1.1.1 sessionid=3360617615 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0

5 logs returned.
```
*or directly cat the log file from container*

```
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/fos-deployment-8ssms --  tail -f /var/log/log/traffic.0
date=2023-03-15 time=08:32:04 eventtime=1678869124 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 srcport=53772 dstip=1.1.1.1 dstport=443 sessionid=1070264054 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:03:44 eventtime=1678871024 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=32 dstip=1.1.1.1 sessionid=912886433 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:05:47 eventtime=1678871147 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 srcport=58914 dstip=1.1.1.1 dstport=443 sessionid=507646218 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:09:45 eventtime=1678871385 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=35 dstip=1.1.1.1 sessionid=1935580230 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-03-15 time=09:10:46 eventtime=1678871446 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.253 identifier=41 dstip=1.1.1.1 sessionid=3360617615 proto=1 action="accept" policyid=3 service="ICMP" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
```

- ## cfos utm feature 
*in this section, we config cfos to test web filter feature and ips feature use https traffic* 

- ### web filter feature 

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl exec -it po/`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  --  curl -k -I  https://www.eicar.org/download/eicar.com.txt
HTTP/1.1 403 Forbidden
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: frame-ancestors 'self'
Content-Type: text/html; charset="utf-8"
Content-Length: 5211
Connection: Close
```
above you can see the access to malicious website has been blocked by cFOS, as the HTTP return code is "403 Forbidden".

- ###  Check log on cFOS
the pod that access malicious is on node ip-10-0-2.200. so we need use cFOS POD on same node to check the block log.

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl exec -it po/`kubectl get pods -l app=fos --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  -- tail -f -n 1 /var/log/log/webf.0
ubuntu@ip-10-0-1-100:~/202301/opa/demo_network_policy_1$ kubectl exec -it po/`kubectl get pods -l app=fos --field-selector spec.nodeName=ip-10-0-2-200 |     cut -d ' ' -f 1 | tail -n -1`  -- tail -f -n 1 /var/log/log/webf.0
date=2023-03-15 time=09:17:52 eventtime=1678871872 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=4 srcip=10.1.128.253 srcport=48986 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"

```
you can see that cFOS have logged the block with reason - "Maliciou Websites".

- ### ips inspect feature 

*we can use curl to generate attack traffic to target ip address, this traffic will be detected by cfos and block it* 
```
ubuntu@ip-10-0-1-100:~/202301$ kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1  ; done
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
command terminated with exit code 28
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
command terminated with exit code 28
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0
curl: (28) Operation timed out after 5000 milliseconds with 0 bytes received
command terminated with exit code 28

```
- ### check cfos ips block log 


```
ubuntu@ip-10-0-1-100:~/202301$ ./checkipslog.sh
date=2023-03-15 time=09:21:46 eventtime=1678872106 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.128.253 dstip=1.1.1.1 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=44084 dstport=443 hostname="1.1.1.1" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=10485761 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-03-15 time=09:21:41 eventtime=1678872101 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.128.253 dstip=1.1.1.1 srcintf="net1" dstintf="eth0" sessionid=2 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=56174 dstport=443 hostname="1.1.1.1" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=167772161 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2023-03-15 time=09:21:51 eventtime=1678872111 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.128.253 dstip=1.1.1.1 srcintf="net1" dstintf="eth0" sessionid=2 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=60116 dstport=443 hostname="1.1.1.1" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=29360129 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
```
or use cfos console 

```
FOS Container # execute  log filter category 4

FOS Container # execute  log filter device disk

FOS Container # execute log display
date=2023-03-15 time=09:21:46 eventtime=1678872106 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.1.128.253 dstip=1.1.1.1 srcintf="net1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTPS" policyid=3 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=44084 dstport=443 hostname="1.1.1.1" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=10485761 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"

1 logs returned.
```
