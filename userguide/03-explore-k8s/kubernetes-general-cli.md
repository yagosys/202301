-  ### kubernetes annotation 

*kubenetes annotation is a key-value pair and its  a way to attach metadata to object. clients such as tools and library can read this metadata*

```
kubectl patch deployment nginx -p '{"spec": {"template":{"metadata":{"annotations":{"k8s.v1.cni.cncf.io/networks":"cfosdefaultcni5"}}}} }'
deployment.apps/nginx patched
```

once it patched. the deployment now has a new annotation

```
ubuntu@ip-10-0-2-200:~/202301/deployment$ kubectl describe deployment nginx
Name:                   nginx
Namespace:              default
CreationTimestamp:      Mon, 27 Feb 2023 03:07:03 +0000
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 3
                        k8s.v1.cni.cncf.io/networks: cfosdefaultcni5
                        spec.template.metadata.annotations.k8s.v1.cni.cncf.io/networks: cfosdefaultcni5
Selector:               app=nginx
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:       app=nginx
  Annotations:  k8s.v1.cni.cncf.io/networks: cfosdefaultcni5
                kubectl.kubernetes.io/restartedAt: 2023-02-28T00:50:38Z
  Containers:
   nginx:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-6dc6dbcbf (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m12s  deployment-controller  Scaled up replica set nginx-6dc6dbcbf to 1
  Normal  ScalingReplicaSet  2m8s   deployment-controller  Scaled down replica set nginx-7d9879b9b5 to 1 from 2
  Normal  ScalingReplicaSet  2m8s   deployment-controller  Scaled up replica set nginx-6dc6dbcbf to 2 from 1
  Normal  ScalingReplicaSet  2m4s   deployment-controller  Scaled down replica set nginx-7d9879b9b5 to 0 from 1

```
also the pod will now have a new nic with ip address according the annotations

```
ubuntu@ip-10-0-2-200:~/202301/deployment$ kubectl describe po/nginx-6dc6dbcbf-m6wpk  | head -n 27
Name:             nginx-6dc6dbcbf-m6wpk
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-10-0-2-200/10.0.2.200
Start Time:       Tue, 28 Feb 2023 01:01:31 +0000
Labels:           app=nginx
                  pod-template-hash=6dc6dbcbf
Annotations:      k8s.v1.cni.cncf.io/network-status:
                    [{
                        "name": "default-cni-network",
                        "interface": "eth0",
                        "ips": [
                            "10.244.1.7"
                        ],
                        "mac": "92:17:c2:fe:a5:d8",
                        "default": true,
                        "dns": {}
                    },{
                        "name": "default/cfosdefaultcni5",
                        "interface": "net1",
                        "ips": [
                            "10.1.128.5"
                        ],
                        "mac": "96:7a:01:9a:59:7f",
                        "dns": {}
                    }]
```

- ### get help from api-resources 

*everything is kubernetes is API, also include customer defined resource, for example, the net-attach-def CRD, it's api-group is "k8s.cni.cncf.io"*
*so we can use kubectl api-resources to check it*

```
kubectl api-resources --api-group=k8s.cni.cncf.io
NAME                             SHORTNAMES       APIVERSION           NAMESPACED   KIND
network-attachment-definitions   net-attach-def   k8s.cni.cncf.io/v1   true         NetworkAttachmentDefinition
```

then we can use `kubectl explain network-attachment-definitions` to to the detail spec. 

for example, below you will find the spec.config definision is cni json formatted config. 

```
ubuntu@ip-10-0-2-200:~/202301/deployment$ kubectl explain network-attachment-definitions.spec.config
KIND:     NetworkAttachmentDefinition
VERSION:  k8s.cni.cncf.io/v1

FIELD:    config <string>

DESCRIPTION:
     NetworkAttachmentDefinition config is a JSON-formatted CNI configuration
```

with this information,you can get the hint that if I have some syntax error in the json-formatted CNI configuration. the kube-API server will not complain it, it will still create a CR (custome resource) for you. however, the CNI plugin will complain the error message.


- ### list pod from selected node
```
kubectl get pods -l app=fos --field-selector spec.nodeName=ip-10-0-2-201
```

- ### scale out the deployment 
```
ubuntu@ip-10-0-1-100:~/202301$ kubectl scale deployment multitool01-deployment --replicas=10
deployment.apps/multitool01-deployment scaled

```
- ### check the status of deployment

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl rollout status deployment multitool01-deployment
deployment "multitool01-deployment" successfully rolled out
ubuntu@ip-10-0-1-100:~/202301$
```

- ### check the status of daemonSet

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl rollout status ds fos-deployment
daemon set "fos-deployment" successfully rolled out
ubuntu@ip-10-0-1-100:~/202301$
```
- ### untaint a master node

```
 kubectl  taint nodes --all node-role.kubernetes.io/control-plane-
```

- ### reapply modified yaml file

```
kubectl -f xxx.yaml replace
```
- ### create resouce from yaml file, it resource already exist, it will fail

```
kubectl -f xxx.yaml create 
```

- ### make the resource reach the state that specified in the yaml file. it does not matter whether the resource already exist

```
kubectl -f xxx.yaml apply
```

- ### use labels

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get node --show-labels
NAME            STATUS   ROLES           AGE     VERSION   LABELS
ip-10-0-2-200   Ready    <none>          7h52m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-0-2-200,kubernetes.io/os=linux
ip-10-0-2-201   Ready    <none>          7h52m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-0-2-201,kubernetes.io/os=linux
ip1001100       Ready    control-plane   7h55m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip1001100,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl label nodes ip-10-0-2-200 node-role.kubernetes.io/worker=worker
node/ip-10-0-2-200 labeled
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl label nodes ip-10-0-2-201 node-role.kubernetes.io/worker=worker
node/ip-10-0-2-201 labeled
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get node --show-labels
NAME            STATUS   ROLES           AGE     VERSION   LABELS
ip-10-0-2-200   Ready    worker          7h53m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-0-2-200,kubernetes.io/os=linux,node-role.kubernetes.io/worker=worker
ip-10-0-2-201   Ready    worker          7h53m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-0-2-201,kubernetes.io/os=linux,node-role.kubernetes.io/worker=worker
ip1001100       Ready    control-plane   7h55m   v1.26.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip1001100,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
```

- ### remove a node from cluster out of scheduler 

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl cordon ip-10-0-2-201
node/ip-10-0-2-201 cordoned
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get nodes
NAME            STATUS                     ROLES           AGE     VERSION
ip-10-0-2-200   Ready                      worker          7h56m   v1.26.2
ip-10-0-2-201   Ready,SchedulingDisabled   worker          7h56m   v1.26.2
ip1001100       Ready                      control-plane   7h58m   v1.26.2

```
- ### move cordoned node back to scheduler

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl uncordon ip-10-0-2-201
node/ip-10-0-2-201 uncordoned
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get nodes
NAME            STATUS   ROLES           AGE     VERSION
ip-10-0-2-200   Ready    worker          7h58m   v1.26.2
ip-10-0-2-201   Ready    worker          7h58m   v1.26.2
ip1001100       Ready    control-plane   8h      v1.26.2
ubuntu@ip-10-0-1-100:/etc/cni/net.d$
```
