pod=`kubectl get pod | grep multi | cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$pod -- ip vrf exec test1 curl -I -k https://1.1.1.1
