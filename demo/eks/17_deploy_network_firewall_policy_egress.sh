filename="17_network_firewallpolicy_egress.yml"
cat << EOF >$filename
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: createdbygatekeeper
  labels:
    app: cfosegressfirewallpolicy
spec:
  podSelector:
    matchLabels:
      app: multitool
      namespace: default
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
EOF
kubectl apply -f $filename
