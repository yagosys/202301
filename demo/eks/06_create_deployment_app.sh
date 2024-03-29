filename="06_app_with_iproute.yml"

cat << EOF > $filename
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 4
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.200.252"]  } ]'
    spec:
      containers:
        - name: multitool01
          image: praqma/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - ip route add 10.0.0.0/16  via 169.254.1.1; /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF
kubectl apply -f $filename && kubectl rollout status deployment/multitool01-deployment  && kubectl get pod -l app=multitool01

