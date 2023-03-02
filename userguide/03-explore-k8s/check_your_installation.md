if the deployment is not sucessful, you may need go to aws console to check what actually installed. 
if the deployment is sucessful. it shall give you the ip address of deployed instance. 

you also see retrive the IP address later with command 


```
terraform output
instance_public_ip = "13.212.24.193"
workernode_instance_public_ip = [
  "13.229.225.111",
  "13.212.176.163",
]
```


ssh into the master node

```
 ssh -i ~/.ssh/id_ed25519cfoslab ubuntu@13.212.24.193

```
check your kubernetes installation 

- check k8s node
```
ubuntu@ip-10-0-1-100:~$ kubectl get node
NAME            STATUS   ROLES           AGE   VERSION
ip-10-0-2-200   Ready    worker          10h   v1.26.1
ip-10-0-2-201   Ready    worker          10h   v1.26.1
ip1001100       Ready    control-plane   10h   v1.26.1
"Ready" means the node is working properly.
```

- check cluster information

```
ubuntu@ip-10-0-1-100:~$ kubectl cluster-info
Kubernetes control plane is running at https://10.0.1.100:6443
CoreDNS is running at https://10.0.1.100:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

*the kubeAPI is listening on 10.0.1.100:6443 , the DNS by default is CoreDNS*.    

check cluster information

```
ubuntu@ip-10-0-1-100:~$ kubectl cluster-info
Kubernetes control plane is running at https://10.0.1.100:6443
CoreDNS is running at https://10.0.1.100:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
*the kubeAPI is listening on 10.0.1.100:6443 , the DNS by default is CoreDNS*.  

the kubeAPI service  and DNS is providing essential service for POD. use command to check

```
ubuntu@ip-10-0-1-100:~$ kubectl get svc kubernetes
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   10h

ubuntu@ip-10-0-1-100:~$ kubectl get svc kube-dns -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   10h
```

verify whether the coredns is working 
```
ubuntu@ip-10-0-1-100:~$ dig @10.96.0.10 www.fortinet.com  | grep "ANSWER SECTION" -A 2
;; ANSWER SECTION:
www.fortinet.com.       30      IN      CNAME   fortinet.96983.fortiwebcloud.net.
fortinet.96983.fortiwebcloud.net. 30 IN CNAME   lb-2.ap-southeast-1.prod.aws.waas-online.net.
```
those are essential service that needed by other POD, for example, cfos will use 10.96.0.1 to read configmap. 

check pod status
```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -o wide -n kube-system
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
coredns-599c97c45f-4dtxw            1/1     Running   0          10h   10.244.0.3   ip1001100       <none>           <none>
coredns-599c97c45f-lkdrr            1/1     Running   0          10h   10.244.0.2   ip1001100       <none>           <none>
etcd-ip1001100                      1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-apiserver-ip1001100            1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-controller-manager-ip1001100   1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-multus-ds-gz67b                1/1     Running   0          10h   10.0.2.201   ip-10-0-2-201   <none>           <none>
kube-multus-ds-m5bbj                1/1     Running   0          10h   10.0.2.200   ip-10-0-2-200   <none>           <none>
kube-multus-ds-qkppk                1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-proxy-hfz7v                    1/1     Running   0          10h   10.0.2.200   ip-10-0-2-200   <none>           <none>
kube-proxy-hm2f7                    1/1     Running   0          10h   10.0.2.201   ip-10-0-2-201   <none>           <none>
kube-proxy-p5ldt                    1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-scheduler-ip1001100            1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
whereabouts-7hspr                   1/1     Running   0          10h   10.0.2.201   ip-10-0-2-201   <none>           <none>
whereabouts-wgws4                   1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
whereabouts-x6qv4                   1/1     Running   0          10h   10.0.2.200   ip-10-0-2-200   <none>           <none>
```

*above show coredns POD on master node,  mutlus node and whereabout pod is on all node. the kube-apiserver , kube-controller-manager, kube-scheduler is on master node. kube-proxy is also on all node.*   

the kubelet is directly running as systemd serivice in each node. 

```
ubuntu@ip-10-0-1-100:~$ systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: active (running) since Sun 2023-02-26 22:55:37 UTC; 10h ago
       Docs: https://kubernetes.io/docs/home/
   Main PID: 18139 (kubelet)
      Tasks: 11 (limit: 9401)
     Memory: 42.1M
        CPU: 12min 17.294s
     CGroup: /system.slice/kubelet.service
             └─18139 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --conf>

ubuntu@ip-10-0-1-100:~$
```

the container runtime crio is also running directly as systemd service 
```
ubuntu@ip-10-0-1-100:~$ systemctl status crio
● crio.service - Container Runtime Interface for OCI (CRI-O)
     Loaded: loaded (/lib/systemd/system/crio.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2023-02-26 22:54:25 UTC; 10h ago
       Docs: https://github.com/cri-o/cri-o
   Main PID: 12863 (crio)
      Tasks: 12
     Memory: 1.1G
        CPU: 2min 16.473s
     CGroup: /system.slice/crio.service
             └─12863 /usr/bin/crio
```

the flannel is  running on kube-flannel namespace

```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -n kube-flannel -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP           NODE            NOMINATED NODE   READINESS GATES
kube-flannel-ds-65smf   1/1     Running   0          10h   10.0.2.201   ip-10-0-2-201   <none>           <none>
kube-flannel-ds-677n6   1/1     Running   0          10h   10.0.1.100   ip1001100       <none>           <none>
kube-flannel-ds-jwrrz   1/1     Running   0          10h   10.0.2.200   ip-10-0-2-200   <none>           <none>
```


check the installed configmap for cfos
```
ubuntu@ip-10-0-1-100:/var/log$ kubectl get cm fos-license
NAME          DATA   AGE
fos-license   1      3d7h
```

check the installed dockerpull secret
```
ubuntu@ip-10-0-1-100:/var/log$ kubectl get secret dockerinterbeing
NAME               TYPE                             DATA   AGE
dockerinterbeing   kubernetes.io/dockerconfigjson   1      3d7h
```


