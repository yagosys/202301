#!/bin/bash
[[ $ping_dst == "" ]] && ping_dst="1.1.1.1"
echo "check whether application pod can reach  $ping_dst"
echo "check deployment multi"
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 $ping_dst ; done
