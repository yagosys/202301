filename="07_deployment_newtest.yml"
cat << EOF > $filename
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testtest-deployment
  labels:
      app: newtest
spec:
  replicas: 2
  selector:
    matchLabels:
        app: newtest
  template:
    metadata:
      labels:
        app: newtest
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'
    spec:
      initContainers:
      - name: init-wait
        image: alpine
        command: ["sh", "-c", "ip route add 10.0.0.0/16 via 169.254.1.1"]
        securityContext:
          capabilities:
            add: ["NET_ADMIN"]
      containers:
        - name: newtest
          image: praqma/network-multitool
          imagePullPolicy: Always
          securityContext:
            privileged: true
EOF
kubectl apply  -f $filename && kubectl rollout status deployment/testtest-deployment &&   kubectl get pod -l app=newtest

