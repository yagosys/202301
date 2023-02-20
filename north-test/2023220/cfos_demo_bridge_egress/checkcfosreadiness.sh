#!/bin/bash

while :
do
  cfospod=`kubectl get pod | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
  multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`

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
