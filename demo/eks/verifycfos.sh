#!/bin/bash

while :
do

nodeName=`kubectl get node | cut -d ' ' -f 1 | tail -1`
kubectl rollout status deployment multitool01-deployment
cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`

  result=$(kubectl exec -it po/$multpod -- curl -k  https://1.1.1.1 2>&1 | grep -o 'decryption failed or bad record mac')
  if [ "$result" = "decryption failed or bad record mac" ]
  then
   echo "cfos is not ready, delete cfos pod"
   kubectl delete po/$cfospod
  else
          echo "cfos is ready"
          break
  fi

done
