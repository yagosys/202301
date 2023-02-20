cfospod=`kubectl get pod | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$multpod -- curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1
kubectl exec -it po/$cfospod -- tail -f /data/var/log/log/ips.0
kubectl get pod | grep multi | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- curl -k -I  https://www.eicar.org/download/eicar.com.txt ; done
kubectl exec -it po/$cfospod -- tail -f /data/var/log/log/webf.0
