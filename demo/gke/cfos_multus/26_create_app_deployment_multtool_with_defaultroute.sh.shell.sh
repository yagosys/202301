filename="26_create_app_deployment_multtool_with_defaultroute.sh.shell.sh.yml.sh"
[[ $cfosIpshort == "" ]] && cfosIpshort="10.1.200.252" 
[[ -z $app_nad_annotation  ]] && app_nad_annotation="cfosapp"
annotations="k8s.v1.cni.cncf.io/networks: '[ { \"name\": \"$app_nad_annotation\", \"default-route\": [\"$cfosIpshort\"] } ]'"
[[ $app_image == "" ]] && app_image="praqma/network-multitool"
[[ -z $app_deployment_label ]] && app_deployment_label="multitool01"

cat << OUTER_EOF > $filename
cat << EOF | kubectl create -f - 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_deployment_label-deployment
  labels:
      app: $app_deployment_label
spec:
  replicas: 4
  selector:
    matchLabels:
        app: $app_deployment_label
  template:
    metadata:
      labels:
        app: $app_deployment_label
      annotations:
        $annotations
    spec:
      containers:
        - name: $app_deployment_label
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

kubectl rollout status deployment $app_deployment_label-deployment
echo "sleep 30 seconds for it will take some time to trigger policymanager to update cfos addressgrp"
sleep 30
OUTER_EOF
chmod +x $filename
./$filename
