nodeName="ip-10-0-2-200"
cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`

kubectl exec -it po/$multpod -- curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1
kubectl exec -it po/$cfospod -- tail -f /data/var/log/log/ips.0

nodeName="ip-10-0-2-201"
cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`

kubectl exec -it po/$multpod -- curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1
kubectl exec -it po/$cfospod -- tail -f /data/var/log/log/ips.0
