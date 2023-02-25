cd /home/ubuntu/202301/north-test/2023220/flannel
kubectl get node  |  grep ip- | awk '{print $1}' |  while read line; do kubectl label nodes $line   kubernetes.io/role=worker --overwrite  ; done
/home/ubuntu/202301/north-test/2023220/flannel/deploycfosdemo.sh
kubectl rollout status ds/fos-deployment
kubectl rollout restart ds/fos-deployment
kubectl rollout status ds/fos-deployment
kubectl create -f app.yaml
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200 sudo ip  add add 10.1.128.1/24 dev cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201 sudo ip  add add 10.1.128.1/24 dev cni5

