#!/bin/bash -x
nodeList=$(kubectl get node | grep "Ready" | awk '{ print $1 }')
index=0
for name in $nodeList; do {
	echo $name
	kubectl label node $name os=linux$index --overwrite
	(( index++))
}
done

kubectl create namespace $1
[[ -z $1 ]] && namespace="default" || namespace=$1
kubectl create -f pvc.yaml -n $namespace
kubectl create -f fazcontainer.yaml -n $namespace
kubectl rollout status deployment fortianalyzer-deployment -n $namespace
kubectl create -f slb.yaml -n $namespace

