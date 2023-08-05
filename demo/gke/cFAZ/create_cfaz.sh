#!/bin/bash -x
kubectl create namespace fortianalyzer
[[ -z $namespace ]] && namespace="fortianalyzer"
kubectl create -f pvc.yaml -n $namespace
kubectl create -f fazcontainer.yaml -n $namespace
kubectl rollout status deployment fortianalyzer-deployment -n $namespace
kubectl create -f slb.yaml -n $namespace

