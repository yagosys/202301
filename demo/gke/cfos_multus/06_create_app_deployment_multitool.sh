file="app_with_annotations_cfosapp.yml"
[[ $app_image == "" ]] && app_image="praqma/network-multitool"
annotations="k8s.v1.cni.cncf.io/networks: '[ { \"name\": \"$app_nad_annotation\" } ]'"
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
        $annotations
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
