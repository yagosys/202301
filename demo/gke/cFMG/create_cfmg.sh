#!/bin/bash -x
[[ -z $namespace ]] && namespace="default" 
kubectl create -f pvc.yaml -n $namespace
kubectl create -f fmgcontainer.yaml -n $namespace
kubectl rollout status deployment fortimanager-deployment
kubectl create -f slb.yaml -n $namespace

