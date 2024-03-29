filename="05_cfos_ds_restservice.yml"
cat << EOF > $filename
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: fos
  name: fos-deployment
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: fos
  type: ClusterIP
---

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fos-deployment
  labels:
      app: fos
spec:
  selector:
    matchLabels:
        app: fos
  template:
    metadata:
      labels:
        app: fos
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.200.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
    spec:
      containers:
      - name: fos
        #image: interbeing/fos:v7231x86
        image: 732600308177.dkr.ecr.ap-east-1.amazonaws.com/fos:v7231x86
        imagePullPolicy: Always
        securityContext:
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
        hostPath:
          path: /cfosdata
          type: DirectoryOrCreate
EOF
kubectl create -f $filename && kubectl rollout status ds/fos-deployment 
kubectl get pod -l app=fos && 
kubectl logs  $(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}') &&
cfospodname=$(kubectl get pod -l app=fos -o jsonpath='{.items[0].metadata.name}') && 
echo "check cfos ip address"
kubectl exec -it po/$cfospodname -- ip a 
echo "check cfos routing table"
kubectl exec -it po/$cfospodname -- ip route
echo "check cfos pod description"
kubectl describe po/$cfospodname



