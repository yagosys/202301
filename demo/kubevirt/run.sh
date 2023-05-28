#!/bin/bash -xe
export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | sort -r | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
echo $VERSION
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml

kubectl rollout status deployment -n kubevirt && 
kubectl rollout status ds -n kubevirt && 
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"

while true; do
  PHASE=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o jsonpath="{.status.phase}")
  if [ "$PHASE" == "Deployed" ]; then
    break
  else
    echo "Waiting for status.phase to become Deployed, current phase: $PHASE"
    sleep 10
  fi
done
echo "Status.phase is now Deployed"


echo  install virtcl client  
#export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
export KUBEVIRT_VERSION=$VERSION
wget -O ~/virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64
chmod +x ~/virtctl
sudo install ~/virtctl /usr/local/bin

echo "disable kvm"
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'

echo #install localhost storageclass
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl rollout status deployment/local-path-provisioner  -n local-path-storage


echo  intall data importor 
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml && 
kubectl -n cdi scale deployment/cdi-operator --replicas=1 && 
kubectl -n cdi rollout status deployment/cdi-operator 

echo - install crd for cdi 
kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi --timeout=600s && 
kubectl -n cdi get pods
sleep 10 

cat << EOF  > ~/fmgdv.yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "fmg"
spec:
  source:
    http:
      url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmg707.qcow2" # S3 or GCS
      #url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/faz74.qcow2" # S3 or GCS
  pvc:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: "5000Mi"
EOF

kubectl apply -f ~/fmgdv.yaml

cat << EOF  > ~/fmgvm.yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  labels:
    kubevirt.io/os: linux
  name: fmg
spec:
  running: true
  template:
    metadata:
      creationTimestamp: null
      labels:
        kubevirt.io/domain: fmg
        app: fmg
    spec:
      domain:
        cpu:
          cores: 4
        devices:
          disks:
          - disk:
              bus: virtio
            name: disk0
          - cdrom:
              bus: sata
              readonly: true
            name: cloudinitdisk
        resources:
          requests:
            memory: 2000M
      volumes:
      - name: disk0
        persistentVolumeClaim:
          claimName: fmg
      - cloudInitNoCloud:
          userData: |
            #cloud-config
            hostname: fmg
            ssh_pwauth: True
            disable_root: false
            ssh_authorized_keys:
            - ssh-rsa YOUR_SSH_PUB_KEY_HERE
        name: cloudinitdisk
EOF
kubectl apply -f ~/fmgvm.yaml
