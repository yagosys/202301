#!/bin/bash -xe
kubectl -n kube-system create serviceaccount ftntconnector
kubectl create clusterrolebinding service-admin --clusterrole=cluster-admin --serviceaccount=kube-system:ftntconnector
token=$(kubectl create token ftntconnector -n kube-system)
echo $token
