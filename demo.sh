cd /home/ubuntu/202301/north-test/2023220/flannel
kubectl label nodes ip-10-0-2-200   kubernetes.io/role=worker --overwrite
kubectl label nodes ip-10-0-2-201   kubernetes.io/role=worker --overwrite
/home/ubuntu/202301/north-test/2023220/flannel/03_deploy.sh
kubectl rollout status ds/fos-deployment
kubectl rollout restart ds/fos-deployment
kubectl rollout status ds/fos-deployment
kubectl create -f app.yaml

