kubednsip=$(kubectl get svc kube-dns -n kube-system -o jsonpath={.spec.clusterIP})
cat << EOF | sudo tee -a /etc/resolv.conf
nameserver $kubednsip
EOF


