#!/bin/bash -x
nodeList=$(kubectl get node | grep "Ready" | awk '{ print $1 }')
index=0
for name in $nodeList; do {
	echo $name
	kubectl label node $name os=linux$index --overwrite
	(( index++))
}
done

[[ -z $1 ]] && namespace="default"  || namespace=$1
kubectl create namespace $namespace
kubectl create -f pvc.yaml -n $namespace
kubectl create -f fmgcontainer.yaml -n $namespace
kubectl rollout status deployment fortimanager-deployment
kubectl create -f slb.yaml -n $namespace

