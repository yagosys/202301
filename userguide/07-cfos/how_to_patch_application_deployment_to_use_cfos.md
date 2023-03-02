- mark your application deployment to use cfos


create a nginx deployment with kubectl 

```
kubectl create deployment mynginxtest01 --image=nginx --replicas=4

```

this nginx deployment will use kubernetes cluster default network. so the traffic will not goes to cfos for inspection. 

```
ubuntu@ip-10-0-1-100:~$ kubectl get pod -l app=mynginxtest01 -o wide
NAME                             READY   STATUS    RESTARTS   AGE    IP            NODE            NOMINATED NODE   READINESS GATES
mynginxtest01-65d7866db6-8q7vx   1/1     Running   0          2m8s   10.244.1.26   ip-10-0-2-200   <none>           <none>
mynginxtest01-65d7866db6-bsjxh   1/1     Running   0          2m8s   10.244.2.18   ip-10-0-2-201   <none>           <none>
mynginxtest01-65d7866db6-fvnt6   1/1     Running   0          2m8s   10.244.2.17   ip-10-0-2-201   <none>           <none>
mynginxtest01-65d7866db6-r95wf   1/1     Running   0          2m8s   10.244.1.27   ip-10-0-2-200   <none>           <none>

```

check the deployment use cluser default network 

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ grep default-cni-network /etc/cni/net.d/00-multus.conf
      "name": "default-cni-network",

ubuntu@ip-10-0-1-100:~$ kubectl get  po/mynginxtest01-65d7866db6-8q7vx -o  json |  jq '.metadata.annotations' -C
{
  "k8s.v1.cni.cncf.io/network-status": "[{\n    \"name\": \"default-cni-network\",\n    \"interface\": \"eth0\",\n    \"ips\": [\n        \"10.244.1.26\"\n    ],\n    \"mac\": \"e6:0b:4f:ad:ad:b7\",\n    \"default\": true,\n    \"dns\": {}\n}]",
  "k8s.v1.cni.cncf.io/networks-status": "[{\n    \"name\": \"default-cni-network\",\n    \"interface\": \"eth0\",\n    \"ips\": [\n        \"10.244.1.26\"\n    ],\n    \"mac\": \"e6:0b:4f:ad:ad:b7\",\n    \"default\": true,\n    \"dns\": {}\n}]"
}

```
the nginx pod shall able to access malicious website as the traffic is not go through the cfos.

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl exec -it po/mynginxtest01-65d7866db6-69j57 -- curl -k -I https://www.eicar.org/download/eicar.com.txt | grep HTTP/1.1
HTTP/1.1 200 OK
```

patch the deployment to attach to secondary network , pod will be redeployed  with a new network. 

```
kubectl patch deployment mynginxtest01 -p '{"spec": {"template":{"metadata":{"annotations":{"k8s.v1.cni.cncf.io/networks":"[{\"name\": \"cfosdefaultcni5\", \"default-route\": [\"10.1.128.2\"]}]"}}}}}'
deployment.apps/mynginxtest01 patched

ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl get po/mynginxtest01-5c4b6874-9p96n  -o  json |  jq '.metadata.annotations' -C
{
  "k8s.v1.cni.cncf.io/network-status": "[{\n    \"name\": \"default-cni-network\",\n    \"interface\": \"eth0\",\n    \"ips\": [\n        \"10.244.2.23\"\n    ],\n    \"mac\": \"de:1c:7a:b5:6f:26\",\n    \"default\": true,\n    \"dns\": {}\n},{\n    \"name\": \"default/cfosdefaultcni5\",\n    \"interface\": \"net1\",\n    \"ips\": [\n        \"10.1.128.14\"\n    ],\n    \"mac\": \"fa:81:59:0d:8f:8d\",\n    \"dns\": {}\n}]",
  "k8s.v1.cni.cncf.io/networks": "[{\"name\": \"cfosdefaultcni5\", \"default-route\": [\"10.1.128.2\"]}]",
  "k8s.v1.cni.cncf.io/networks-status": "[{\n    \"name\": \"default-cni-network\",\n    \"interface\": \"eth0\",\n    \"ips\": [\n        \"10.244.2.23\"\n    ],\n    \"mac\": \"de:1c:7a:b5:6f:26\",\n    \"default\": true,\n    \"dns\": {}\n},{\n    \"name\": \"default/cfosdefaultcni5\",\n    \"interface\": \"net1\",\n    \"ips\": [\n        \"10.1.128.14\"\n    ],\n    \"mac\": \"fa:81:59:0d:8f:8d\",\n    \"dns\": {}\n}]"
}

now you will see that access to malicious website has been blocked by cfos. 

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ kubectl exec -it po/mynginxtest01-5c4b6874-9p96n -- curl -k -I https://www.eicar.org/download/eicar.com.txt | grep HTTP/1.1
HTTP/1.1 403 Forbidden
```



