- ## bridge cni use whereabouts ipam 
```
{
            "cniVersion": "0.4.0",
            "plugins": [
              {
                "name": "cfosdefaultcni5",
                "type": "bridge",
                "isGateway": false,
                "bridge": "cni5",
                "ipMasq": false,
                "ipam": {
                    "type": "whereabouts",
                    "range": "10.1.128.0/24",
                    "gateway": "10.1.128.2",
                    "log_file": "/tmp/whereabouts.log",
                    "log_level": "debug",
                    "routes": [
                      {
                        "dst": "10.96.0.0/12",
                        "gw": "10.1.128.1"
                      },
                      {
                        "dst": "10.0.0.2/32",
                        "gw": "10.1.128.1"
                      }
                    ],
                    "exclude": [
                      "10.1.128.1/32",
                      "10.1.128.2/32",
                      "10.1.128.254/32"
                    ]
                }
             }
            ]
}

```
- ## flannel cni use whereabouts ipam
*when use whereabouts with flannel. each worker node need have a seperate podCIDR, so you will need create cni config for each node with different podCIDR (range in whereabouts spec)*
*then create an multus CRD to associate with cni config on each node*
*here is an example that with two worker node*

```
cat  << EOF | kubectl apply -f - 
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: flannel1
EOF 
```
create flannel_cni_conf on each worker node directory /etc/cni/multus/net.d/
*on node 1*
```
{
  "cniVersion": "0.3.1",
  "type": "flannel",
  "name": "flannel1",
  "ipam": {
  "type": "whereabouts",
     "range": "10.244.0.0/24",
     "gateway": "10.244.0.1",
     "log_file": "/tmp/whereabouts.log",
     "log_level": "debug",
     "routes": [
        {
          "dst": "10.96.0.0/12",
          "gw": "10.244.0.1"
        },
        { "dst": "10.0.0.2/32",
          "gw": "10.244.0.1"
        }
     ],
     "exclude": [
        "10.244.0.1/32"
     ]
  },
  "delegate": {
    "isDefaultGateway": true,
    "hairpinMode": true
  }
}
```
*on node2*
```
{
  "cniVersion": "0.3.1",
  "type": "flannel",
  "name": "flannel1",
  "ipam": {
  "type": "whereabouts",
     "range": "10.244.1.0/24",
     "gateway": "10.244.1.1",
     "log_file": "/tmp/whereabouts.log",
     "log_level": "debug",
     "routes": [
        {
          "dst": "10.96.0.0/12",
          "gw": "10.244.0.1"
        },
        { "dst": "10.0.0.2/32",
          "gw": "10.244.1.1"
        }
     ],
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
*then create a application deployment to use this crd flannel1*


```
cat << EOF | kubectl -f -

apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: flannel1
  namespace: default
EOF

```

*then create a deployment to use this crd*
*since this crd is created on namespace default, so the annotations on deployment need use format "default/flannel1"*
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  labels:
      app: app
spec:
  replicas: 2
  selector:
    matchLabels:
        app: app
  template:
    metadata:
      labels:
        app: app
      annotations:
        v1.multus-cni.io/default-network: default/flannel1
    spec:
      containers:
        - name: app
          #image: wbitt/network-test
          image: docker.io/wbitt/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
```

*the pod from this deployment will use ip from whereabouts*

```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -o wide
NAME                                     READY   STATUS              RESTARTS   AGE     IP            NODE            NOMINATED NODE   READINESS GATES
app-deployment-7d9966f56f-hmm7d          1/1     Running             0          5m13s   10.244.0.2    ip1001100       <none>           <none>
app-deployment-7d9966f56f-qkzqz          1/1     Running             0          5m13s   10.244.1.2    ip-10-0-2-200   <none>           <none>
```
ubuntu@ip-10-0-1-100:~$ kubectl describe po/app-deployment-7d9966f56f-hmm7d
Name:             app-deployment-7d9966f56f-hmm7d
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip1001100/10.0.1.100
Start Time:       Thu, 16 Mar 2023 04:00:30 +0000
Labels:           app=app
                  pod-template-hash=7d9966f56f
Annotations:      k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "default/flannel1",
                        "interface": "eth0",
                        "ips": [
                            "10.244.0.2"
                        ],
                        "mac": "26:7f:25:05:60:6b",
                        "default": true,
                        "dns": {}
                    }]
                  k8s.v1.cni.cncf.io/networks-status:
                    [{
                        "name": "default/flannel1",
                        "interface": "eth0",
                        "ips": [
                            "10.244.0.2"
                        ],
                        "mac": "26:7f:25:05:60:6b",
                        "default": true,
                        "dns": {}
                    }]
                  v1.multus-cni.io/default-network: default/flannel1
Status:           Running
IP:               10.244.0.2
IPs:
  IP:           10.244.0.2
Controlled By:  ReplicaSet/app-deployment-7d9966f56f
Containers:
  app:
    Container ID:  cri-o://04b74e26d6f5f5458c17d49ad33cc6974d11b6df398ce917aa6aa4edfd690f96
    Image:         docker.io/wbitt/network-multitool
    Image ID:      docker.io/wbitt/network-multitool@sha256:82583afc5117b0ae69483d42476dc612a6624f4fa608c2d5890ed6ee5c38747d
    Port:          <none>
    Host Port:     <none>
    Args:
      /bin/sh
      -c
      /usr/sbin/nginx -g "daemon off;"
    State:          Running
      Started:      Thu, 16 Mar 2023 04:00:33 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rd848 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-rd848:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason          Age    From               Message
  ----    ------          ----   ----               -------
  Normal  Scheduled       6m47s  default-scheduler  Successfully assigned default/app-deployment-7d9966f56f-hmm7d to ip1001100
  Normal  AddedInterface  6m46s  multus             Add eth0 [10.244.0.2/24] from default/flannel1
  Normal  Pulling         6m46s  kubelet            Pulling image "docker.io/wbitt/network-multitool"
  Normal  Pulled          6m44s  kubelet            Successfully pulled image "docker.io/wbitt/network-multitool" in 2.367819562s (2.367826675s including waiting)
  Normal  Created         6m44s  kubelet            Created container app
  Normal  Started         6m44s  kubelet            Started container app
```
*two pod are reachable each other*
```
ubuntu@ip-10-0-1-100:~$ kubectl exec -it po/app-deployment-7d9966f56f-hmm7d -- ping 10.244.1.2
PING 10.244.1.2 (10.244.1.2) 56(84) bytes of data.
64 bytes from 10.244.1.2: icmp_seq=1 ttl=62 time=0.354 ms
```
