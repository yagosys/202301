kubectl scale deployment testtest-deployment --replicas=4 && kubectl rollout status deployment/testtest-deployment &&
kubectl get pod -l app=newtest && 
kubectl get pod | grep testtest | awk '{print $1}'  | while read line; do kubectl  exec po/$line -- ip -4 --br a show dev net1; done

