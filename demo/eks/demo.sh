kubectl create -f multus-daemonset.yml
kubectl create -f nad_bridge_cni_10_0_200_cfosdefauultcni5.yaml
kubectl rollout status ds/kube-multus-ds -n kube-system
kubectl create -f dockersecret.yaml
kubectl create -f fos_license.yaml
kubectl create -f cfos_firewallpolicy.yaml
kubectl create -f app.yaml
kubectl rollout status deployment 
kubectl create -f cfos_account.yaml
sleep 10
kubectl create -f cfos.yaml
kubectl rollout status ds
