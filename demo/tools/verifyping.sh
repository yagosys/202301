#!/bin/bash

# Get list of node names
node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')


for nodeName in $node_list; do
        kubectl rollout status deployment multitool01-deployment
        cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
        multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`
	iplist=`kubectl get pods -l app=multitool01 -o=jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}'`
        if  kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1
        then
          echo " on $nodeName cfos is ready"
        else
          echo "  "

        fi
	for ip in $iplist; do 
	  echo ping from $multpod to $ip
	  kubectl exec -it po/$multpod -- ping -c 1 $ip
       done
       
done
