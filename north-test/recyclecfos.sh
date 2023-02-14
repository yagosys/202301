kubectl delete -f firewallpolicy.yaml
kubectl delete -f 1_net_attach_10_1_128_ipam_whereabouts.yaml
kubectl delete -f br-10-1-128-1-static-for_cfos.yaml
kubectl delete -f 3_cfosdeployment.yaml
kubectl delete -f deployment_tool_net1.yaml
sleep 30
kubectl apply -f 1_net_attach_10_1_128_ipam_whereabouts.yaml
kubectl apply -f br-10-1-128-1-static-for_cfos.yaml
kubectl apply -f 3_cfosdeployment.yaml
kubectl apply -f deployment_tool_net1.yaml
kubectl apply -f cfosdefaultroute.yaml
kubectl apply -f firewallpolicy.yaml
