kubectl create -f 00_pv_pvc.yaml
kubectl create -f 01_cfos_account.yaml
kubectl create -f 04_cfosfirewallpolicy.yaml
kubectl create -f 05_cfos_dns.yaml
#kubectl create -f net_bridge_secondary_network.yaml
kubectl create -f  net_bridge_secondary_network_full.yaml
kubectl create -f net_new_default_network_for_cfos.yaml
echo deploy cfos daemonSet
kubectl create -f cfosdeployment.yaml
sleep 10
echo deploy application pod
kubectl create -f app.yaml
