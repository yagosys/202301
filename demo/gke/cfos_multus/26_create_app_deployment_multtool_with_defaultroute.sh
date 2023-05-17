file="app_with_annotations_cfosapp_with_defalt_route.yml"
[[ $cfosIpshort == "" ]] && cfosIpshort="10.1.200.252" 
annotation="k8s.v1.cni.cncf.io/networks: '[ { \"name\": \"$app_nad_annotation\", \"default-route\": [\"$cfosIpshort\"] } ]'"
[[ $app_image == "" ]] && app_image="praqma/network-multitool"

cat << EOF > $file 
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
        $annotation
        #k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosapp",  "default-route": ["10.1.200.252"]  } ]' 
    spec:
      containers:
        - name: multitool01
          image: $app_image
          #image: praqma/network-multitool
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            privileged: true
EOF

kubectl create -f $file && kubectl rollout status deployment multitool01-deployment
echo "sleep 30 seconds for it will take some time to trigger policymanager to update cfos addressgrp"
sleep 30
