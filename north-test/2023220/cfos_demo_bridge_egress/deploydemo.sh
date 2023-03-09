kubectl apply -f 00_pv_pvc.yaml
kubectl apply -f 01_cfos_account.yaml
kubectl apply -f net_10_1_128.yaml
kubectl apply -f net_default_10_86_0.yaml
kubectl apply -f 03_cfos_defaultroute.yaml
kubectl apply -f 04_cfosfirewallpolicy.yaml
kubectl apply -f 05_cfos_dns.yaml
kubectl apply -f cfosdeployment.yaml
sleep 10
kubectl apply -f application.yaml
