```
wandy@cloudshell:~$ kubectl describe po/nginx-748c667d99-9hpd8 
Name:             nginx-748c667d99-9hpd8
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-my-first-cluster-1-default-pool-e54a0dbc-zb85/10.0.1.11
Start Time:       Tue, 25 Apr 2023 05:59:46 +0000
Labels:           app=nginx
                  pod-template-hash=748c667d99
Annotations:      k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "k8s-pod-network",
                        "interface": "eth0",
                        "ips": [
                            "10.140.0.10"
                        ],
                        "mac": "3e:49:e6:87:4e:c0",
                        "default": true,
                        "dns": {}
                    }]
                  k8s.v1.cni.cncf.io/networks-status:
                    [{
                        "name": "k8s-pod-network",
                        "interface": "eth0",
                        "ips": [
                            "10.140.0.10"
                        ],
                        "mac": "3e:49:e6:87:4e:c0",
                        "default": true,
                        "dns": {}
                    }]
Status:           Running
IP:               10.140.0.10
IPs:
  IP:           10.140.0.10
Controlled By:  ReplicaSet/nginx-748c667d99
Containers:
  nginx:
    Container ID:   containerd://92b18fd5a53dabddd308e1e42656c409283bc7c63956258e1200b2b3f0208aa3
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:63b44e8ddb83d5dd8020327c1f40436e37a6fffd3ef2498a6204df23be6e7e94
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 25 Apr 2023 05:59:53 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9sj7t (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-9sj7t:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
wandy@cloudshell:~$
```
multus-ds
```
wandy@cloudshell:~$ kubectl logs -f ds/kube-multus-ds -n kube-system
Defaulted container "kube-multus" out of: kube-multus, install-multus-binary (init)
2023-04-25T04:31:41+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-04-25T04:31:41+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-04-25T04:31:42+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-04-25T04:31:42+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
2023-04-25T04:31:43+00:00 Config file created @ /host/etc/cni/net.d/00-multus.conf
{ "cniVersion": "0.3.1", "name": "multus-cni-network", "type": "multus", "capabilities": {"portMappings": true}, "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig", "delegates": [ { "name": "k8s-pod-network", "cniVersion": "0.3.1", "plugins": [ { "type": "ptp", "mtu": 1460, "ipam": { "type": "host-local", "subnet": "10.140.0.0/24", "routes": [ { "dst": "0.0.0.0/0" } ] } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] } ]}
2023-04-25T04:31:43+00:00 Entering sleep (success)...
```

net-attach-def
```
wandy@cloudshell:~$ kubectl get net-attach-def
NAME              AGE
cfosdefaultcni5   69m
wandy@cloudshell:~$ kubectl get net-attach-def -o yaml
apiVersion: v1
items:
- apiVersion: k8s.cni.cncf.io/v1
  kind: NetworkAttachmentDefinition
  metadata:
    creationTimestamp: "2023-04-25T06:01:40Z"
    generation: 1
    name: cfosdefaultcni5
    namespace: default
    resourceVersion: "64983"
    uid: 321ca9d7-57e6-4263-b8a7-e7ff7a5bd9f1
  spec:
    config: '{ "cniVersion": "0.3.0", "type": "macvlan", "master": "eth0", "mode":
      "bridge", "ipam": { "type": "host-local", "subnet": "10.1.200.0/24", "rangeStart":
      "10.1.200.20", "rangeEnd": "10.1.200.253", "gateway": "10.1.200.1" } }'
kind: List
metadata:
  resourceVersion: ""
wandy@cloudshell:~$
```
worker node

```
gke-my-first-cluster-1-default-pool-e54a0dbc-zb85 /etc/cni/net.d # cat 00-multus.conf | jq .
{
  "cniVersion": "0.3.1",
  "name": "multus-cni-network",
  "type": "multus",
  "capabilities": {
    "portMappings": true
  },
  "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig",
  "delegates": [
    {
      "name": "k8s-pod-network",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "ptp",
          "mtu": 1460,
          "ipam": {
            "type": "host-local",
            "subnet": "10.140.0.0/24",
            "routes": [
              {
                "dst": "0.0.0.0/0"
              }
            ]
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
  ]
}
```
binary
```
gke-my-first-cluster-1-default-pool-e54a0dbc-zb85 /home/kubernetes/bin # ls -l
total 579276
-rwxr-xr-x 1 root   root    4001554 Apr 21  2022 bandwidth
-rwxr-xr-x 1 root   root    4415898 Apr 21  2022 bridge
-r-xr--r-- 1 root   root     145235 Mar 14 12:53 configure-helper.sh
-rwxr-xr-x 1 root   root      28927 Mar 14 12:53 configure-kubeapiserver.sh
-rwxr-xr-x 1 root   root      51141 Apr 25 03:56 configure.sh
-rwxr-xr-x 1 root   root   53855555 Mar 14 12:53 containerd-gcfs-grpc
-rwxr-xr-x 1 root   root   52561079 Feb 22 22:20 crictl
-rwxr-xr-x 1 root   root    9793499 Apr 21  2022 dhcp
-rwxr-xr-x 1 root   root    4565386 Apr 21  2022 firewall
-rwxr-xr-x 1 root   root   75341912 Mar 14 12:53 gcfsd
-rwxr-xr-x 1 root   root    4384935 Apr 21  2022 gke
-rwxr-xr-x 1 root   root   38838384 Apr 25 03:56 gke-exec-auth-plugin
-rw-r--r-- 1 root   root     860241 Apr 25 03:57 gke-exec-auth-plugin-license
-rwxr-xr-x 1 root   root      34172 Mar 14 12:53 gke-internal-configure-helper.sh
-rwxr-xr-x 1 root   root       2429 Mar 14 12:53 gke-internal-configure.sh
-rwxr-xr-x 1 344930 89939   7513333 Jun 25  2021 health-checker
-r-xr--r-- 1 root   root       4439 Mar 14 12:53 health-monitor.sh
-rwxr-xr-x 1 root   root    4022219 Apr 21  2022 host-device
-rwxr-xr-x 1 root   root    3413458 Apr 21  2022 host-local
-rwxr-xr-x 1 root   root    4151120 Apr 21  2022 ipvlan
-rwxr-xr-x 1 root   root   62573640 Mar 14 10:56 kubectl
-rwxr-xr-x 1 root   root  123212720 Mar 14 10:56 kubelet
-rwxr-xr-x 1 344930 89939  18258320 Jun 25  2021 log-counter
-rwxr-xr-x 1 root   root    3481573 Apr 21  2022 loopback
-rwxr-xr-x 1 root   root    4223021 Apr 21  2022 macvlan
-rwxr-xr-x 1 root   root   42573547 Apr 25 04:31 multus
-rwxr-xr-x 1 root   root       1290 Mar 14 12:53 networkd-monitor.sh
-rwxr-xr-x 1 344930 89939  44331104 Jun 25  2021 node-problem-detector
-r-xr--r-- 1 root   root      14326 Mar 14 12:53 node-registration-checker.sh
-rwxr-xr-x 1 root   root    3935582 Apr 21  2022 portmap
-rwxr-xr-x 1 root   root    4345324 Apr 21  2022 ptp
-rwxr-xr-x 1 root   root    3688769 Apr 21  2022 sbr
-rwxr-xr-x 1 root   root    2973371 Apr 21  2022 static
-rwxr-xr-x 1 root   root    3632986 Apr 21  2022 tuning
-rwxr-xr-x 1 root   root    4149283 Apr 21  2022 vlan
-rwxr-xr-x 1 root   root    3723134 Apr 21  2022 vrf
```
multus ds
```
wandy@cloudshell:~$ kubectl describe po/kube-multus-ds-hszsc  -n kube-system
Name:             kube-multus-ds-hszsc
Namespace:        kube-system
Priority:         0
Service Account:  multus
Node:             gke-my-first-cluster-1-default-pool-e54a0dbc-zb85/10.0.1.11
Start Time:       Tue, 25 Apr 2023 04:31:38 +0000
Labels:           app=multus
                  controller-revision-hash=7f79769545
                  name=multus
                  pod-template-generation=1
                  tier=node
Annotations:      <none>
Status:           Running
IP:               10.0.1.11
IPs:
  IP:           10.0.1.11
Controlled By:  DaemonSet/kube-multus-ds
Init Containers:
  install-multus-binary:
    Container ID:  containerd://c20afdaaa4a212a8b46071687d14c7fb9950b664cea85c37b16e89ed6710cc91
    Image:         ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
    Image ID:      ghcr.io/k8snetworkplumbingwg/multus-cni@sha256:c173235642a10055db53bc43898fc1058cc6b97178fc3472ce4dafdd6d940d0b
    Port:          <none>
    Host Port:     <none>
    Command:
      cp
      /usr/src/multus-cni/bin/multus
      /host/opt/cni/bin/multus
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Tue, 25 Apr 2023 04:31:39 +0000
      Finished:     Tue, 25 Apr 2023 04:31:39 +0000
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:        10m
      memory:     15Mi
    Environment:  <none>
    Mounts:
      /host/opt/cni/bin from cnibin (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-p9pkr (ro)
Containers:
  kube-multus:
    Container ID:  containerd://758fd15278f543d4c86602ecacd17863231dace99a780ed129462ccfb91fe851
    Image:         ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
    Image ID:      ghcr.io/k8snetworkplumbingwg/multus-cni@sha256:c173235642a10055db53bc43898fc1058cc6b97178fc3472ce4dafdd6d940d0b
    Port:          <none>
    Host Port:     <none>
    Command:
      /entrypoint.sh
    Args:
      --multus-conf-file=auto
      --cni-version=0.3.1
    State:          Running
      Started:      Tue, 25 Apr 2023 04:31:40 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  50Mi
    Requests:
      cpu:        100m
      memory:     50Mi
    Environment:  <none>
    Mounts:
      /host/etc/cni/net.d from cni (rw)
      /host/opt/cni/bin from cnibin (rw)
      /tmp/multus-conf from multus-cfg (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-p9pkr (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  cni:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/cni/net.d
    HostPathType:
  cnibin:
    Type:          HostPath (bare host directory volume)
    Path:          /home/kubernetes/bin
    HostPathType:
  multus-cfg:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      multus-cni-config
    Optional:  false
  kube-api-access-p9pkr:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 :NoSchedule op=Exists
                             :NoExecute op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:                      <none>
wandy@cloudshell:~$
```
