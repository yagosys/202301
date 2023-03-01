flannel is a cluster-wide cni which can provide network solution for cross node communication.
POD in each node use different CIDR then POD on other node in same cluster. when traffic leave node to other node, flannel by default will use vxlan to encapsuation the original POD IP and tunnel to other node.  by default. flannel use vxlan id 1 for tunnel. flannel.1 is the default gateway interface on each node.

flannel by default use 10.244.0.0/16 to assign IP address to POD. flannel handle ip address assignment on it's own, so use flannel with other IPAM like host-local or whereabouts is not necessary.
each node will assigned a different podCIDR, for example, "10.244.1.0/24", "10.244.2.0/24" , "10.244.0.0/24" on different node.
this PodCIDR are saved in each node /run/flannel/subnet.env  

```
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.[x].1/24
FLANNEL_MTU=8951
FLANNEL_IPMASQ=true
```
flannel will delegate the actual bridge creation etc bridge cni. depends on flannel cni config, a bridge and bridge interface on host will be created as bridge between host and POD. 
the default bridge name is cni0, pod in same node can communicate with this bridge

pod on node 1 ---veth ----bridge ----cri0---flannel1.1 ----layer 3 -----flannel1.1----cri0----bridge---veth --- pod on node2



1. install flannel

2. check flannel installation 

```
ubuntu@ip-10-0-1-100:~/202301/north-test/2023220/cfos_demo_bridge_egress$ kubectl get ds kube-flannel-ds -n kube-flannel
NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-flannel-ds   3         3         3       3            3           <none>          30h
```

```
ubuntu@ip-10-0-1-100:~/202301/north-test/2023220/cfos_demo_bridge_egress$ kubectl logs ds/kube-flannel-ds -n kube-flannel -c kube-flannel
Found 3 pods, using pod/kube-flannel-ds-65smf
I0227 23:20:35.346495       1 main.go:211] CLI flags config: {etcdEndpoints:http://127.0.0.1:4001,http://127.0.0.1:2379 etcdPrefix:/coreos.com/network etcdKeyfile: etcdCertfile: etcdCAFile: etcdUsername: etcdPassword: version:false kubeSubnetMgr:true kubeApiUrl: kubeAnnotationPrefix:flannel.alpha.coreos.com kubeConfigFile: iface:[] ifaceRegex:[] ipMasq:true ifaceCanReach: subnetFile:/run/flannel/subnet.env publicIP: publicIPv6: subnetLeaseRenewMargin:60 healthzIP:0.0.0.0 healthzPort:0 iptablesResyncSeconds:5 iptablesForwardRules:true netConfPath:/etc/kube-flannel/net-conf.json setNodeNetworkUnavailable:true useMultiClusterCidr:false}
W0227 23:20:35.349683       1 client_config.go:617] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
I0227 23:20:35.397205       1 kube.go:144] Waiting 10m0s for node controller to sync
I0227 23:20:35.397278       1 kube.go:482] Starting kube subnet manager
I0227 23:20:35.408830       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.1.0/24]
I0227 23:20:35.408928       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.2.0/24]
I0227 23:20:35.408955       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.0.0/24]
I0227 23:20:36.397496       1 kube.go:151] Node controller sync successful
I0227 23:20:36.397527       1 main.go:231] Created subnet manager: Kubernetes Subnet Manager - ip-10-0-2-201
I0227 23:20:36.397532       1 main.go:234] Installing signal handlers
I0227 23:20:36.397745       1 main.go:542] Found network config - Backend type: vxlan
I0227 23:20:36.397788       1 match.go:206] Determining IP address of default interface
I0227 23:20:36.398060       1 match.go:259] Using interface with name ens5 and address 10.0.2.201
I0227 23:20:36.398083       1 match.go:281] Defaulting external address to interface address (10.0.2.201)
I0227 23:20:36.398135       1 vxlan.go:138] VXLAN config: VNI=1 Port=0 GBP=false Learning=false DirectRouting=false
W0227 23:20:36.428407       1 main.go:595] no subnet found for key: FLANNEL_SUBNET in file: /run/flannel/subnet.env
I0227 23:20:36.428427       1 main.go:481] Current network or subnet (10.244.0.0/16, 10.244.2.0/24) is not equal to previous one (0.0.0.0/0, 0.0.0.0/0), trying to recycle old iptables rules
I0227 23:20:36.429109       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.2.0/24]
I0227 23:20:36.463866       1 main.go:356] Setting up masking rules
I0227 23:20:36.466529       1 main.go:407] Changing default FORWARD chain policy to ACCEPT
I0227 23:20:36.467582       1 iptables.go:274] generated 7 rules
I0227 23:20:36.469718       1 main.go:435] Wrote subnet file to /run/flannel/subnet.env
I0227 23:20:36.469796       1 main.go:439] Running backend.
I0227 23:20:36.470165       1 iptables.go:274] generated 3 rules
I0227 23:20:36.470564       1 vxlan_network.go:62] watching for new subnet leases
I0227 23:20:36.487533       1 main.go:460] Waiting for all goroutines to exit
I0227 23:20:36.488785       1 iptables.go:267] bootstrap done
I0227 23:20:36.498224       1 iptables.go:267] bootstrap done
I0227 23:20:37.023021       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.1.0/24]
I0227 23:20:37.028162       1 kube.go:503] Creating the node lease for IPv4. This is the n.Spec.PodCIDRs: [10.244.0.0/24]
```
3. here lets create a default network with flannel plugins and assign to pod [TODO]

create a default network with flannel plugins

```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: test
  namespace: kube-system
spec:
  config: |-
    {
            "cniVersion": "0.3.1",
            "plugins": [
              {
                 "type": "flannel",
                 "name": "flannel1",
                 "delegate": {
                 "bridge": "test0"
                  }
              },
              {
                "type": "portmap",
                "capabilities": {
                "portMappings": true
                 }
              }
            ]
    }
```

above will create a net-attach-def which using flannel cni.
the flannel cni will delegate the actual bridge operation to bridge cni. the bridge cni will create a bridge called test0 according the configuration. the flannel interface flannel1 will take care the cross-node communication. 
flannel can also support use multiple tunnel interface configration. for example you want use flannel2. and flannel2 use vxlan id 2 . if you want do this. please refer url <TODO> 
 

```
ubuntu@ip-10-0-2-200:~$ ip add show dev test0
36: test0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default qlen 1000
    link/ether 52:9e:fd:65:cc:5a brd ff:ff:ff:ff:ff:ff
    inet 10.244.1.1/24 brd 10.244.1.255 scope global test0
       valid_lft forever preferred_lft forever
    inet6 fe80::509e:fdff:fe65:cc5a/64 scope link
       valid_lft forever preferred_lft forever
```

create a yaml file to create a POD to use this network

```
ubuntu@ip-10-0-1-100:~$ cat nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      annotations:
        v1.multus-cni.io/default-network: test
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

then you will get two POD with one on each node.  they are reachable.



4. create a node specifc network  
first create a net-attach-def with only metadata name and namespace


```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: flannel1
  namespace: kube-system

```

then create cni config on each node 

no  node 201
```
ubuntu@ip-10-0-2-201:/etc/cni/multus/net.d$ cat test.conf
{
  "cniVersion": "0.4.0",
  "type": "flannel",
  "name": "flannel1",
  "ipam": {
  "type": "whereabouts",
     "range": "10.244.2.0/24",
     "gateway": "10.244.2.1",
     "exclude": [
        "10.244.2.1/32"
     ]
  },
  "delegate": {
    "isDefaultGateway": true,
    "hairpinMode": true
  }
}
```
on node 200

```
{
  "cniVersion": "0.4.0",
  "type": "flannel",
  "name": "flannel1",
  "ipam": {
  "type": "whereabouts",
     "range": "10.244.1.0/24",
     "gateway": "10.244.1.1",
     "exclude": [
        "10.244.1.1/32"
     ]
  },
  "delegate": {
    "isDefaultGateway": true,
    "hairpinMode": true
  }
}
```

because each node has different CIDR for flannel, so we have to use range and gateway that match subnet definision.

also, we can use whereabouts ipam to execlude some ip address to be assigned to pod. 

then create net-attach-def and add annotations to pod.


```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: flannel1
  namespace: kube-system
```


```
ubuntu@ip-10-0-1-100:~$ cat nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      annotations:
        v1.multus-cni.io/default-network: "flannel1"
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80

```
these nginix pod can communicate each other cross the node.

```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -l app=nginx -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
nginx-deployment-67449f94bd-ksf8f   1/1     Running   0          38m   10.244.1.2   ip-10-0-2-200   <none>           <none>
nginx-deployment-67449f94bd-mvzj2   1/1     Running   0          38m   10.244.2.3   ip-10-0-2-201   <none>           <none>
nginx-deployment-67449f94bd-n5kzj   1/1     Running   0          38m   10.244.2.2   ip-10-0-2-201   <none>           <none>
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/nginx-deployment-67449f94bd-ksf8f -- curl -I  http://10.244.2.3
HTTP/1.1 200 OK
Server: nginx/1.23.3
Date: Tue, 28 Feb 2023 09:41:29 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 13 Dec 2022 15:53:53 GMT
Connection: keep-alive
ETag: "6398a011-267"
Accept-Ranges: bytes

ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/nginx-deployment-67449f94bd-ksf8f -- curl -I  http://10.244.2.2
HTTP/1.1 200 OK
Server: nginx/1.23.3
Date: Tue, 28 Feb 2023 09:41:33 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 13 Dec 2022 15:53:53 GMT
Connection: keep-alive
ETag: "6398a011-267"
Accept-Ranges: bytes

ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/nginx-deployment-67449f94bd-ksf8f -- curl -I  http://10.244.1.2
HTTP/1.1 200 OK
Server: nginx/1.23.3
Date: Tue, 28 Feb 2023 09:41:36 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 13 Dec 2022 15:53:53 GMT
Connection: keep-alive
ETag: "6398a011-267"
Accept-Ranges: bytes
```


here are few useful command 


check the flannel.1 tunnel interface. you can see vxlan id 1 , and dstport 8472. 

``
3: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether 4a:3b:64:c8:96:10 brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 68 maxmtu 65535
    vxlan id 1 local 10.0.1.100 dev ens5 srcport 0 0 dstport 8472 nolearning ttl auto ageing 300 udpcsum noudp6zerocsumtx noudp6zerocsumrx addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
``` 

