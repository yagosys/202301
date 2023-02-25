kubectl delete -f cfosdeployment.yaml
kubectl delete -f net_bridge_secondary_network.yaml
kubectl delete -f net_new_default_network_for_cfos.yaml
kubectl delete -f cfosdeployment.yaml
kubectl delete -f app.yaml
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200 sudo ip  link delete cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201 sudo ip  link delete cni5
