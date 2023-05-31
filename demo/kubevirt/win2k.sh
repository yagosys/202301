#!/bash -xe
filename="pvc100gforw2k9.yaml"
storageclassname="local-path"
cat << EOF > $filename
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: winhd
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: $storageclassname
EOF
kubectl apply -f $filename
