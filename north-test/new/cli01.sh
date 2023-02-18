echo 'cfos interface address'
cfospod=`kubectl get pod | grep fos01 | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$cfospod -- ip  -4 -p -h -br a

echo 'multitool pod interface addaddress and default route'
multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$multpod -- ip  -4 -p -h -br a
kubectl exec -it po/$multpod -- ip -4 -p -h -br  route | grep default

echo 'check whether multitool can reach internet'
kubectl exec -it po/$multpod -- ping -c 2 -I net1 1.1.1.1 

echo 'issue normal curl'
kubectl exec -it po/$multpod -- curl -k -I https://1.1.1.1

echo 'issue curl with attack '
sleep 1
kubectl exec -it po/$multpod --  curl --max-time 5  -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1

echo 'check attak log on cfos'
sleep 1
kubectl exec -it po/$cfospod -- tail -n 1 /data/var/log/log/ips.0

kubectl get pod | grep multi | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- curl -k -I  https://www.eicar.org/download/eicar.com.txt ; done

