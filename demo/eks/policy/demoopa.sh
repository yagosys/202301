kubectl apply -f gatekeeper.yaml &&
kubectl rollout status deployment/gatekeeper-audit -n gatekeeper-system && 
kubectl rollout status deployment/gatekeeper-controller-manager  -n gatekeeper-system

kubectl apply -f template_addrgrp.yaml &&
kubectl get constrainttemplate k8segressnetworkpolicytocfosutmpolicy && 
kubectl apply -f constraint_addrgrp.yaml &&  
kubectl get k8segressnetworkpolicytocfosutmpolicy cfosnetworkpolicy && 
kubectl create -f  networkPolicySameple.yaml  
kubectl apply -f watchandupdatcfospodip.yaml
