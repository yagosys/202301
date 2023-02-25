cd /home/ubuntu/202301/north-test/2023220/flannel
kubectl get node  |  grep ip- | awk '{print $1}' |  while read line; do kubectl label nodes $line   kubernetes.io/role=worker --overwrite  ; done
/home/ubuntu/202301/north-test/2023220/flannel/deploycfosdemo.sh
kubectl rollout status ds/fos-deployment
kubectl rollout restart ds/fos-deployment
kubectl rollout status ds/fos-deployment
kubectl create -f app.yaml

