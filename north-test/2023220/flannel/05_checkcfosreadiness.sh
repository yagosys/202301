#!/bin/bash

while :
do

nodeName="ip-10-0-2-200"
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

while :
do

nodeName="ip-10-0-2-201"
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
