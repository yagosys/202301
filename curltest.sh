kubectl get pod | grep multi | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- curl -k -I https://1.1.1.1 ; done
