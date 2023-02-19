kubectl apply -f 00_net-10-1-128.yaml
kubectl apply -f 00_pv_pvc.yaml
kubectl apply -f 01_cfos_account.yaml
kubectl apply -f 02_cfos01.yaml
kubectl apply -f 03_cfos_defaultroute.yaml
kubectl apply -f 04_cfosfirewallpolicy.yaml
kubectl apply -f 05_cfos_dns.yaml
kubectl apply -f 05_multtool_with_defaultroute01.yaml
cfospod=`kubectl get pod | grep fos01 | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
sleep 30
kubectl delete po/$cfospod
