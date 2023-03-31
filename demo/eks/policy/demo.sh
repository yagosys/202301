kubectl apply -f gatekeeper.yaml && kubectl apply -f template_addrgrp.yaml ; kubectl apply -f constraint_addrgrp.yaml; kubectl create -f  networkPolicySameple.yaml
kubectl apply -f watchandupdatcfospodip.yaml
