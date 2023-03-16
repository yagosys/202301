- ## check kube-dns

- ### check whether coredns pod has IP address

*coredns ds will get ip address from cni plugin, if there is no cni exist or cni is not working properl. coredns POD will not able to get ip, you need install and config cni first*

- ### check kube-dns service*
```
ubuntu@ip-10-0-1-100:~$ kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   82m
```
- ### check kube-dns is able to resolve local service*
```
ubuntu@ip-10-0-1-100:~$ dig kubernetes.default.svc.cluster.local @10.96.0.10 | grep -A 1 'ANSWER SECTION'
;; ANSWER SECTION:
kubernetes.default.svc.cluster.local. 30 IN A   10.96.0.1
ubuntu@ip-10-0-1-100:~$
```

- ### check kube-dns is able to resolve internet address*

```
ubuntu@ip-10-0-1-100:~$ dig www.google.com @10.96.0.10 | grep -A 1 'ANSWER SECTION'
;; ANSWER SECTION:
www.google.com.         30      IN      A       172.217.31.4
```

- ### check master dns resolve config*

```
ubuntu@ip-10-0-1-100:~$ resolvectl status
Global
           Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
    resolv.conf mode: stub
  Current DNS Server: 10.96.0.10
         DNS Servers: 10.96.0.10 8.8.8.8
Fallback DNS Servers: 10.0.0.2
          DNS Domain: cluster.local

Link 2 (ens5)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 10.0.0.2
       DNS Servers: 10.0.0.2
        DNS Domain: ap-east-1.compute.internal

Link 6 (flannel.1)
Current Scopes: none
     Protocols: -DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported

Link 7 (cni0)
Current Scopes: none
     Protocols: -DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported

Link 8 (veth4ea19122)
Current Scopes: none
     Protocols: -DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported

Link 9 (vethb02e94c2)
Current Scopes: none
     Protocols: -DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
ubuntu@ip-10-0-1-100:~$
```
- ### check master node whether can resolve k8s service name*
```
ubuntu@ip-10-0-1-100:~$ curl -k https://kubernetes.default.svc.cluster.local
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}
```

- ### some useful throubleshooting command

```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -l  k8s-app=kube-dns -n kube-system -o wide
NAME                       READY   STATUS    RESTARTS   AGE    IP           NODE        NOMINATED NODE   READINESS GATES
coredns-6f7d9964b8-hxrwj   1/1     Running   0          104m   10.244.0.3   ip1001100   <none>           <none>
coredns-6f7d9964b8-wr8kg   1/1     Running   0          104m   10.244.0.2   ip1001100   <none>           <none>

ubuntu@ip-10-0-1-100:~$ kubectl describe deployment coredns -n kube-system | grep ness
    Liveness:     http-get http://:8080/health delay=60s timeout=5s period=10s #success=1 #failure=5
    Readiness:    http-get http://:8181/ready delay=0s timeout=1s period=10s #success=1 #failure=3

ubuntu@ip-10-0-1-100:~$ kubectl rollout restart deployment coredns -n kube-system
deployment.apps/coredns restarted
ubuntu@ip-10-0-1-100:~$ kubectl rollout status deployment coredns -n kube-system
deployment "coredns" successfully rolled out

ubuntu@ip-10-0-1-100:~$ kubectl logs -f po/$(kubectl get pod -l  k8s-app=kube-dns -n kube-system --field-selector status.phase=Running -o jsonpath={.items[].metadata.name}) -n kube-system
.:53
[INFO] plugin/reload: Running configuration SHA512 = 591cf328cccc12bc490481273e738df59329c62c0b729d94e8b61db9961c2fa5f046dd37f1cf888b953814040d180f52594972691cd6ff41be96639138a43908
CoreDNS-1.9.3
linux/amd64, go1.18.2, 45b0a11

```
