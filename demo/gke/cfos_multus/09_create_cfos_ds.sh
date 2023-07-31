#!/bin/bash -xe 
file="cfos_ds.yml" 
[[ $cfos_image == "" ]] && cfos_image="interbeing/fos:v7231x86"
[[ $cfosIp == "" ]] && cfosIp="10.1.200.252/32"
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $cfos_data_host_path ]] && cfos_data_host_path="/home/kubernetes/cfosdata"
[[ -z $net_attach_def_name_for_cfos ]] && net_attach_def_name_for_cfos="cfosdefaultcni5"



annotations="k8s.v1.cni.cncf.io/networks: '[ { \"name\": \"$net_attach_def_name_for_cfos\",  \"ips\": [ \"$cfosIp\" ], \"mac\": \"CA:FE:C0:FF:00:02\" } ]'"

cat << EOF > $file
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $cfos_label
  name: $cfos_label-deployment
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  #sessionAffinity: ClientIP
  selector:
    app: $cfos_label
  type: ClusterIP
---

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: $cfos_label-deployment
  labels:
      app: $cfos_label
spec:
  selector:
    matchLabels:
        app: $cfos_label
  template:
    metadata:
      labels:
        app: $cfos_label
      annotations:
        $annotations
        #k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
    spec:
      containers:
      - name: $cfos_label
        image: $cfos_image
        #image: 732600308177.dkr.ecr.ap-east-1.amazonaws.com/fos:v7231x86
        imagePullPolicy: Always
        securityContext:
          privileged: true
          capabilities:
              add: ["NET_ADMIN","SYS_ADMIN","NET_RAW"]
        ports:
        - name: isakmp
          containerPort: 500
          protocol: UDP
        - name: ipsec-nat-t
          containerPort: 4500
          protocol: UDP
        volumeMounts:
        - mountPath: /data
          name: data-volume
      imagePullSecrets:
      - name: dockerinterbeing
      volumes:
      - name: data-volume
        #persistentVolumeClaim:
          #claimName: filestore-pvc
        hostPath:
          path: $cfos_data_host_path
          type: DirectoryOrCreate
EOF

kubectl create -f $file  && \

kubectl rollout status ds/$cfos_label-deployment && kubectl get pod -l app=$cfos_label
