pod=`kubectl get pod | grep multi | cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$pod -- ip vrf exec test1 curl -I -k https://1.1.1.1
kubectl exec -it po/$pod -- ip vrf exec test1 curl -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1
cfospod=`kubectl get pod | grep fos | cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$cfospod -- tail -f /data/var/log/log/ips.0
