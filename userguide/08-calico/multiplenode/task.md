- install calico

*let's use Calico Tigera Operator to install calico , 
The Calico Tigera Operator is a Kubernetes operator designed to simplify the installation and management of the Calico networking and network policy solution on Kubernetes clusters. Calico is an open-source networking and network policy solution for Kubernetes and other cloud-native platforms.*

The Calico Tigera Operator automates the deployment of Calico on Kubernetes, which can be complex and time-consuming to do manually. The operator uses a declarative configuration model, which allows you to define the desired state of your Calico deployment, and the operator will ensure that the actual state matches the desired state.

`calictl` is a command-line tool that allows you to interact with Calico to manage networking and network security policies on a Kubernetes cluster. this is optional. but will be useful for throubleshooting. 

Custom resources are extensions to the Kubernetes API that allow you to define and use resources beyond the built-in resources that come with Kubernetes. Calico uses custom resources to provide additional functionality beyond what is available with standard Kubernetes resources.

We need to modify Custom resources to enable containerIPForwarding and also change podCIDR to match cluster podCIDR configuration. 

for detail about Custom resources spec. use `kubectl explain Installation.spec`. 


```
sudo curl -fL https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o /usr/local/bin/calicoctl
sudo chmod +x /usr/local/bin/calicoctl
curl -fLO https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
kubectl create -f tigera-operator.yaml
curl -fLO https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
sed -i -e "s?blockSize: 26?blockSize: 24?g" custom-resources.yaml
sed -i -e "s?VXLANCrossSubnet?VXLAN?g" custom-resources.yaml
sed -i -e "s?192.168.0.0/16?10.244.0.0/16?g" custom-resources.yaml
sed -i '/calicoNetwork:/a\    containerIPForwarding: Enabled ' custom-resources.yaml
sed -i '/calicoNetwork:/a\    bgp: Disabled ' custom-resources.yaml
```
- check calico installation 
use `kubectl get node -o json | jq .items[].metadata.annotations` to check the annotations added by calico , you can find podCIDR for each node.
use `kubectl get installation default -o yaml` to check the Custome resources installed by calico 
use `kubectl get all -n calico-system` to check calico resources is up and running 
use `kubectl get all -n calico-apiserver` to check api server is up and running 
use `sudo calicoctl node status` to check the  calico status and networking 

- install  multus 

Multus CNI is a Container Network Interface (CNI) plugin for Kubernetes that allows multiple network interfaces to be attached to a Kubernetes pod. This means that a pod can have multiple network interfaces, each with its own IP address, and can communicate with different networks simultaneously. 

When installing Multus CNI for Kubernetes, the multus-conf-file parameter by default set with the value "auto" which  means that Multus will automatically detect the configuration file to use.
The configuration file specifies how Multus CNI should operate and which network interfaces should be created for the pods. By default, Multus looks for a configuration file in the directory /etc/cni/net.d/ and uses the first configuration file it finds. If no configuration file is found, Multus uses a default configuration. 

We can config cni for Multus to use manually, so we change the "auto" to 70-multus.conf. the 70-multus.conf often will not become the first CNI for kubernetes if you already have installed calico or flannel etc other CNI. By default, the 70-multus.conf file includes bridge , loopback CNI, we do not need that.  

we can manually pull multu-cni installation package beforehand if you have a slow network or we can directly clone it from internent and install it with kubectl 
```
sudo crictl pull ghcr.io/k8snetworkplumbingwg/multus-cni:stable
cd /home/ubuntu
git clone https://github.com/intel/multus-cni.git
sudo sed -i 's/multus-conf-file=auto/multus-conf-file=\/tmp\/multus-conf\/70-multus.conf/g' /home/ubuntu/multus-cni/deployments/multus-daemonset.yml
cat /home/ubuntu/multus-cni/deployments/multus-daemonset.yml | kubectl apply -f -
```
- check the multus installation 

- create directory /etc/cni/multus/net.d  on each node 

```
for node in 10.0.2.200 10.0.2.201 10.0.1.100; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@$node  sudo mkdir -p /etc/cni/multus/net.d
done
```

- create 00-multus.conf under /etc/cni/net.d which use net-calico as default network

```
for node in 10.0.2.200 10.0.2.201 10.0.1.100; do 
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@$node << EOF
cat << INNER_EOF | sudo tee /etc/cni/net.d/00-multus.conf.bak
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

- create net-calico multus crd with cni config under /etc/cni/multus/net.d as cluster default network 

*net-calico net-attach-def*

```
cat << EOF | kubectl apply -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: net-calico
  namespace: kube-system
EOF 
```
- create net-calico cni config on master node 

```
nodes=("10.0.1.100" "10.0.2.200" "10.0.2.201")
cidr=("10.244.6" "10.244.97" "10.244.93")
for i in "${!nodes[@]}"; do
ssh -o "StrictHostKeyChecking=no" -i  ~/.ssh/id_ed25519cfoslab ubuntu@"${nodes[$i]}" << EOF 
cat << INNEREOF | sudo tee /etc/cni/multus/net.d/net-calico.conf.bak
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

- check crio log on each node

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ journalctl -f -u crio | grep 'Updated default CNI network name'
Mar 13 02:46:54 ip-10-0-1-100 crio[2449]: time="2023-03-13 02:46:54.059049524Z" level=info msg="Updated default CNI network name to multus-cni-network"
Mar 13 02:46:54 ip-10-0-1-100 crio[2449]: time="2023-03-13 02:46:54.132076903Z" level=info msg="Updated default CNI network name to multus-cni-network"
```
- verify multus now delegates to net-calico cni for default cluster network 
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


- create default-calico multus crd with cni config under /etc/cni/multus/net.d on each node with different pod sub for application that want to route traffic to cfos 

```
cat << EOF | kubectl apply -f - 
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: default-calico
  namespace: kube-system
EOF 

```
*default-calico cni* under /etc/cni/multus/net.d*
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


- creaete a pod on default network to verify 
```
kubectl create deployment normal --image=praqma/network-multitool --replicas=3
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/normal-6965c788cf-s2r2h -- ip r
default via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
```
- change previous deployment to use new default network 
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


- create multus secondary network with bridge cni 
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
- patch normal deployment to use secondary bridge network and add a default route 
```
kubectl patch deployment normal -p '{"spec": {"template":{"metadata":{"annotations":{"k8s.v1.cni.cncf.io/networks":"[{\"name\": \"cfosdefaultcni5\", \"default-route\": [\"10.1.128.2\"]}]"}}}}}'

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
/ # ip r
default via 10.1.128.2 dev net1
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.2
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link

```
- create cfos 

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
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.128.2/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
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
        persistentVolumeClaim:
          claimName: cfosdata
EOF 
```
- verify pod in normal application now shall able to access internet via cfos

```
ubuntu@ip-10-0-1-100:~/202301/north-test/2023220/flannel-default$ kubectl exec -it po/normal-58945bc79d-25784 -- sh
/ # ip r
default via 10.1.128.2 dev net1
10.0.0.0/8 via 169.254.1.1 dev eth0
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.3
10.96.0.0/12 via 10.1.128.1 dev net1
10.96.0.0/12 via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
/ # curl ipinfo.io
{
  "ip": "54.169.149.19",
  "hostname": "ec2-54-169-149-19.ap-southeast-1.compute.amazonaws.com",
  "city": "Singapore",
  "region": "Singapore",
  "country": "SG",
  "loc": "1.2830,103.8487",
  "org": "AS16509 Amazon.com, Inc.",
  "postal": "048464",
  "timezone": "Asia/Singapore",
  "readme": "https://ipinfo.io/missingauth"
}/ #
```

- create a test application that use cfos 
```
cat << EOF | kubectl apply -f - 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app01-deployment
  labels:
      app: app01
spec:
  replicas: 3
  selector:
    matchLabels:
        app: app01
  template:
    metadata:
      labels:
        app: app01
      annotations:
        #k8s.v1.cni.cncf.io/networks: '[ { "name": "br-10-244-2",  "ips": [ "10.244.2.3/32"], "default-route": ["10.244.2.2"]  } ]'
        v1.multus-cni.io/default-network: default-calico
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.128.2"]  } ]'
    spec:
      containers:
        - name: app01
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
            privileged: true
EOF 
```
