kubectl create -f 00_pv_pvc.yaml
kubectl create -f 01_cfos_account.yaml
kubectl create -f 04_cfosfirewallpolicy.yaml
kubectl create -f 05_cfos_dns.yaml
kubectl create -f 02_cfos_static_route.yaml
kubectl create -f  net_bridge_secondary_network_full.yaml
echo deploy cfos daemonSet
kubectl create -f cfosdeployment.yaml
