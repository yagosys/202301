pwd="/home/ubuntu/202301/north-test/2023220/flannel-default"
cd $pwd
kubectl get node  |  grep ip- | awk '{print $1}' |  while read line; do kubectl label nodes $line   kubernetes.io/role=worker --overwrite  ; done
./03_deploy.sh
kubectl rollout status ds/fos-deployment
kubectl rollout restart ds/fos-deployment
kubectl rollout status ds/fos-deployment
kubectl create -f app_calico_ipam_route_sh.yaml
./05_checkcfosreadiness.sh

