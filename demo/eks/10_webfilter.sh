kubectl get pod | grep multi | grep -v termin | awk '{print $1}'  | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.eicar.org/download/eicar.com.txt  ; done
kubectl get pod -l app=newtest | grep "Running" | awk '{print $1}' | while read line; do kubectl exec -t po/$line --  curl -k -I  https://www.eicar.org/download/eicar.com.txt  ; done

