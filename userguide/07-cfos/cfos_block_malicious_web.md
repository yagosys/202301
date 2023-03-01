- POD access malicious web site

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl get pod -o wide
NAME                                      READY   STATUS    RESTARTS   AGE     IP            NODE            NOMINATED NODE   READINESS GATES
fos-deployment-chqxj                      1/1     Running   1          5h14m   10.244.2.24   ip-10-0-2-201   <none>           <none>
fos-deployment-mcjq7                      1/1     Running   1          5h15m   10.244.1.21   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-5sn2r   1/1     Running   1          5h12m   10.244.1.22   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-cjrbn   1/1     Running   1          5h14m   10.244.2.22   ip-10-0-2-201   <none>           <none>
multitool01-deployment-748ff87bfb-cnf7t   1/1     Running   1          5h14m   10.244.1.20   ip-10-0-2-200   <none>           <none>
multitool01-deployment-748ff87bfb-n958n   1/1     Running   1          5h12m   10.244.2.23   ip-10-0-2-201   <none>           <none>
ubuntu@ip-10-0-1-100:~/202301$

ubuntu@ip-10-0-1-100:~/202301$ kubectl exec -it po/multitool01-deployment-748ff87bfb-5sn2r --  curl -k -I  https://www.eicar.org/download/eicar.com.txt
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

- Check log on cFOS 
the pod that access malicious is on node ip-10-0-200. so we need use cFOS POD on same node to check the block log.

```
ubuntu@ip-10-0-1-100:~/202301$ kubectl exec -it po/fos-deployment-mcjq7 -- tail -f -n 1 /var/log/log/webf.0
date=2023-03-01 time=06:13:27 eventtime=1677651207 tz="+0000" logid="0316013056" type="utm" subtype="webfilter" eventtype="ftgd_blk" level="warning" policyid=3 sessionid=2 srcip=10.1.128.3 srcport=49464 srcintf="net1" dstip=89.238.73.97 dstport=443 dstintf="eth0" proto=6 service="HTTPS" hostname="www.eicar.org" profile="default" action="blocked" reqtype="direct" url="https://www.eicar.org/download/eicar.com.txt" sentbyte=100 rcvdbyte=0 direction="outgoing" msg="URL belongs to a denied category in policy" method="domain" cat=26 catdesc="Malicious Websites"

```
you can see that cFOS have logged the block with reason - "Maliciou Websites".
```


