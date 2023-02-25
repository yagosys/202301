kubectl delete deployment multitool01-deployment
kubectl delete ds/fos-deployment
kubectl delete net-attach-def cfosdefaultcni5
kubectl delete net-attach-def br-default-flannel -n kube-system
kubectl delete service fos-deployment
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200 sudo ip  link delete cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201 sudo ip  link delete cni5

