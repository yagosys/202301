```

1 cfos is container version of fortios. it meet the oci standard, so can be run under docker, containered, and crio runtime.

cfos offer l7 security feature such as IPS, DNS filter, Web filter, SSL deep inspection etc., also cfos provide real time updated security update from fortiguard. These updates help detect and prevent cyberattacks, block malicious traffic, and provide secure access to resources.

when deploy cfos in k8s, it can protect IP traffic from POD egress to internet and also can protect east-west traffic between different POD CIDR subnet. this is enabled by add multus CNI, 
 with multus, cfos can use one interface for control plane communication, such as access to k8s API, expose serice to external world etc., while use other interface dedicated for inspect traffic from other POD. to seperate the control plane traffic with data plane traffic. the additional interface can be associated with high performance NIC such as the interface that has SRIOV enabled for high performance and lowest latency. 

Use case : POD egress security 

Pod egress security is important because it helps organizations protect their networks and data from potential threats that may come from outgoing traffic from pods in their kubernetes clusters. Here are some reasons why pod egress security is crucial:

Prevent data exfiltration: Without proper egress security controls, a malicious actor could potentially use an application running in a pod to exfiltrate sensitive data from the cluster.

Control outgoing traffic: By restricting egress traffic from pods to specific IP addresses or domains, organizations can prevent unauthorized communication with external entities and control access to external resources.

Comply with regulatory requirements: Many regulations require organizations to implement controls around outgoing traffic to ensure compliance with data privacy and security regulations. Implementing pod egress security controls can help organizations meet these requirements.

Prevent malware infections: A pod that is compromised by malware could use egress traffic to communicate with external command and control servers, leading to further infections and data exfiltration. Egress security controls can help prevent these types of attacks.

Overall, implementing pod egress security controls is an important part of securing kubernetes clusters and ensuring the integrity, confidentiality, and availability of organizational data.
in this use case , application can route traffic with dedicated network which created by multus to cfos POD. cfos POD inspect the packet for IPS attack, URL filter, DNS filter etc, if it's SSL encrpyted. cFOS also do deep packet inspection. 

demo setup

the demo setup include an application deployment and cFOS daemonSet. cFOS use fixed IP address, application POD by default route traffic towards cFOS. after cFOS inspected packet based on the firewall policy, the cFOS send traffic to internet from node with sNAT. 

1. create network for cfos and application pod to attach 

Create a new default network  for CFOS pod and other application POD that want use CFOS for egress policy. We do not touch existing cluster default network. 
so the default cluster network behavior will be changed. this make sure the deploy cFOS into cluster is seamless. 


1. create a new cluster default network

assume cluster already have flannel CNI installed, we can create default cluster network which use flannel CNI. the flannl CNI by default will delegate to bridge CNI and use flannel it's own IPAM mechnism. if you want, you can use mac cni like macvlan or ipvlan etc for flannel to delegate, meanwhile, flannel also allow use other IPAM plugins like whereabouts. 

cat EOF << |  kubectl apply -f 
---
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: br-default-flannel
  namespace: kube-system
spec:
  config: |-
    {
            "cniVersion": "0.4.0",
            "plugins": [
              {
                 "type": "flannel",
                 "name": "flannel.1",
                 "delegate": {
                 "isDefaultGateway": true,
                 "hairpinMode": true
                  }
              },
              {
                "type": "portmap",
                "capabilities": {
                "portMappings": true
                 }
              }
            ]

EOF 

2. dataplane traffic network 

we create another network for IP traffic between application POD and CFOS POD. in this example, we use bridge CNI . 
since bridge CNI is host local, therefore we can reuse same IP subnet on each worker node.

cat EOF << |  kubectl create  -f
---
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

application POD that attached to this network will be installed two route that configured in ipam section. the 10.96.0.0/12 is the network for cluter Service IP,
while 10.0.0.2 is the AWS DNS address (when AWS VPC CIDR is 10.0.0.0/16). 10.1.128.1 is the address of cni5 interface on host network. 

3. deploy cFOS daemonSet.

We deploy cFOS as daemonSet, so each worker node will create a CFOS POD, each CFOS use same ip address , cFOS will use local worker node to reach internet. 

in additional to network. cFOS will also need mountpoint for /data fold, so the licesen and configuration, log etc can be saved on this fold. if all worker node want share same /data fold, you can consider to use nfs. 

cfos also need least-privilege to read the configmap from cluster and image pulling secrete. cfos can be configured via configmap or cfos cli/restful API. 

cfos restful interface port 80 is also exposed to cluster via clusterip service. you can also expose cfos ipsec service to external world if needed. 

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
        v1.multus-cni.io/default-network: br-default-flannel
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

some notes about yaml spec : 

kind: DaemonSet
cFOS POD can be configured with static IP  use annotation "ips". 
annotations:  v1.multus-cni.io/default-network: br-default-flannel, assume the default-network is in namespace kube-system, if not, use format like "default/br-default-flannel". 
cFOS can provide IPSEC service to external world. 
cFOS will require "NET_ADMIN" , "SYS_ADMIN" , and "NET_RAW" capabilities to enable packet capture, ping , and syslog feature. 
cFOS can read configmap to get license , and firewall policy, dns config, static router config etc.,


config cfos via configmap 

firewall policy 
cat <<EOF  |  kubectl create apply -f 
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

EOF 

dns config 

cat <<EOF | kubectl create apply -f 
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
      set primary 1.1.1.1
      set secondary 10.0.0.2
    end

EOF 


4 deploy application POD.

we deploy demo application that want use cFOS for egress policy enforcement. the application will config an default route to send all traffic cFOS POD. the default route is come from the annotation. below application POD will have default route point to 10.1.128.2 which is CFOS net1 interface address. 
it will also get a default route from default network, but will be overrided by default route from secondary network.

if you do not want add default route to POD, you can also consider use VRF or SBR etc CNI to select required traffic to cFOS POD. 
 
cat <<EOF | kubectl create -f 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 4
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        v1.multus-cni.io/default-network: br-default-flannel
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.128.2"]  } ]'
    spec:
      containers:
        - name: multitool01
          image: docker.io/wbitt/network-multitool
          imagePullPolicy: Always
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true

EOF 

5. check the deployment result 
ubuntu@ip-10-0-1-100:~$ kubectl get pod -o wide
NAME                                      READY   STATUS    RESTARTS   AGE     IP            NODE            NOMINATED NODE   READINESS GATES
fos-deployment-chqxj                      1/1     Running   0          98s     10.244.2.20   ip-10-0-2-201   <none>           <none>
fos-deployment-mcjq7                      1/1     Running   0          2m10s   10.244.1.17   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-5sn2r   1/1     Running   0          8s      10.244.1.19   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-cjrbn   1/1     Running   0          102s    10.244.2.19   ip-10-0-2-201   <none>           <none>
multitool01-deployment-748ff87bfb-cnf7t   1/1     Running   0          99s     10.244.1.18   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-n958n   1/1     Running   0          8s      10.244.2.21   ip-10-0-2-201   <none>           <none>


cfos have POD on each worker node, while multitool application pod have 2 on each worker node as the replcias: 4. this kubectl command, we will only able to show the default network IP which is from flannel. but not the secondary ip. 


to check secondary address use

ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/fos-deployment-chqxj -- ip --br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0@if14        UP             10.244.2.20/24 fe80::bc7b:88ff:fea2:567f/64
net1@if15        UP             10.1.128.2/24 fe80::c8fe:c0ff:feff:2/64
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/fos-deployment-mcjq7 -- ip --br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0@if12        UP             10.244.1.17/24 fe80::e0e5:1dff:fe6f:ba6b/64
net1@if13        UP             10.1.128.2/24 fe80::c8fe:c0ff:feff:2/64
ubuntu@ip-10-0-1-100:~$

or use  kubectl describe po/fos-deployment-chqxj to check the annotations field

Annotations:      k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "kube-system/br-default-flannel",
                        "interface": "eth0",
                        "ips": [
                            "10.244.2.20"
                        ],
                        "mac": "be:7b:88:a2:56:7f",
                        "default": true,
                        "dns": {}
                    },{
                        "name": "default/cfosdefaultcni5",
                        "interface": "net1",
                        "ips": [
                            "10.1.128.2"
                        ],
                        "mac": "ca:fe:c0:ff:00:02",
                        "dns": {}
                    }]
                  k8s.v1.cni.cncf.io/networks: [ { "name": "cfosdefaultcni5",  "ips": [ "10.1.128.2/32" ], "mac": "CA:FE:C0:FF:00:02" } ]
                  k8s.v1.cni.cncf.io/networks-status:
                    [{
                        "name": "kube-system/br-default-flannel",
                        "interface": "eth0",
                        "ips": [
                            "10.244.2.20"
                        ],
                        "mac": "be:7b:88:a2:56:7f",
                        "default": true,
                        "dns": {}
                    },{
                        "name": "default/cfosdefaultcni5",
                        "interface": "net1",
IP:               10.244.2.20
IPs:
  IP:           10.244.2.20



check the application pod routing table 

ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/multitool01-deployment-748ff87bfb-5sn2r -- ip r
default via 10.1.128.2 dev net1
10.0.0.2 via 10.1.128.1 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.4
10.96.0.0/12 via 10.1.128.1 dev net1
10.244.0.0/16 via 10.244.1.1 dev eth0
10.244.1.0/24 dev eth0 proto kernel scope link src 10.244.1.19


check the application whether able to reach internet

ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/multitool01-deployment-748ff87bfb-5sn2r -- ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=48 time=2.55 ms
^C
--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2.548/2.548/2.548/0.000 ms



```
