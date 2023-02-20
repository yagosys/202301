kubectl apply -f 00_pv_pvc.yaml
sleep 10
kubectl apply -f 01_cfos_account.yaml
sleep 10
kubectl apply -f net_10_1_128.yaml
sleep 10
kubectl apply -f net_default_10_86_0.yaml
sleep 10
kubectl apply -f 03_cfos_defaultroute.yaml
sleep 10
kubectl apply -f 04_cfosfirewallpolicy.yaml
sleep 10
kubectl apply -f 05_cfos_dns.yaml
sleep 10
kubectl apply -f cfosdeployment.yaml
sleep 10
kubectl apply -f application.yaml
sleep 10
