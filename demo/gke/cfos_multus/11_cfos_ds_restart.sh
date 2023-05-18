[[ $ping_dst == "" ]] && ping_dst="1.1.1.1"
[[ -z $cfos_label ]] && cfos_label="fos" 

kubectl rollout status ds/$cfos_label-deployment && \
kubectl rollout restart ds/$cfos_label-deployment && \
kubectl rollout status ds/$cfos_label-deployment && \
podname=$(kubectl get pod -l app=$cfos_label  | grep Running | grep $cfos_label | cut -d " " -f 1) && \
echo   'check cfos iptables for snat entry' && \
kubectl exec -it po/$podname -- iptables -L -t nat --verbose | grep MASQ && \
echo "check whether application pod can reach $ping_dst1"
echo "check deployment multi"
echo sleep 30
sleep 30
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do echo pod $line; kubectl exec -t po/$line -- ping -c1 $ping_dst ; done
echo 'done'
