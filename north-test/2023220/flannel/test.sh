scp  -i ~/.ssh/id_ed25519cfoslab ./createcniconfig.sh 10.0.2.200:
scp  -i ~/.ssh/id_ed25519cfoslab ./createcniconfig.sh 10.0.2.201:
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200  ./createcniconfig.sh
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201  ./createcniconfig.sh
kubectl label nodes ip-10-0-2-200   kubernetes.io/role=worker --overwrite
kubectl label nodes ip-10-0-2-201   kubernetes.io/role=worker --overwrite
