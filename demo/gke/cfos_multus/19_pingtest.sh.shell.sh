echo "check whether application pod can reach  1.1.1.1"
echo "check deployment multi"
kubectl get pod | grep multi | grep -v termin  | awk '{print }'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
