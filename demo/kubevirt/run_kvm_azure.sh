#!/bin/bash -xe
alias "k=kubectl"
echo alias "k=kubectl" >> ~/.bashrc
source ~/.bashrc
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

curl -sfL https://get.k3s.io | sh -s - --disable traefik --write-kubeconfig-mode 644
KUBECONFIG_FILE="/etc/rancher/k3s/k3s.yaml"
export KUBECONFIG=$KUBECONFIG_FILE
echo "Kubeconfig file path: $KUBECONFIG_FILE"
mkdir ~/.kube -p
while [ ! -f "$KUBECONFIG_FILE" ]; do
  sleep 1
done

sudo cp "$KUBECONFIG_FILE" ~/.kube/config
sudo cp "$KUBECONFIG_FILE" /home/adminuser/.kube/config
cp "$KUBECONFIG_FILE" ~/.kube/
sleep 5
kubectl rollout status deployment local-path-provisioner -n kube-system &&  kubectl rollout status deployment metrics-server -n kube-system





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

echo install krew

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" >> ~/.bashrc
echo export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
#kubectl krew install virt


echo #install localhost storageclass
#kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
#kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
#kubectl rollout status deployment/local-path-provisioner  -n local-path-storage

if kvm-ok | grep -q "KVM acceleration can be used"; then
    echo "KVM acceleration is available"
else
    echo "KVM is not available,useEmulation instead"
    kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
fi

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
      #url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmg707.qcow2" # S3 or GCS
      url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmgoracle722.qcow2" # S3 or GCS
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
            memory: 8000M
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
kubectl apply -f ~/fmgvm.yaml  &&

POD_LABEL_SELECTOR="app=fmg"

check_pod_status() {
  local pod_status=$(kubectl get pod -l "$POD_LABEL_SELECTOR" -o jsonpath='{.items[0].status.phase}')
  if [ "$pod_status" = "Running" ]; then
    return 0
  else
    return 1
  fi
}

wait_for_pod_running() {
  until check_pod_status; do
    echo "Waiting for the pod to be in 'Running' state..."
    sleep 5
  done
}

wait_for_pod_running

echo "The pod is now in 'Running' state."


port="443"
nodeport="30443"
cat << EOF > ~/fmgNodePort.yaml
apiVersion: v1
kind: Service
metadata:
  name: fmg$port
spec:
  type: NodePort
  selector:
    app: fmg # Replace this with the labels your pod has
  ports:
    - port: $port
      targetPort: $port
      nodePort: $nodeport
EOF
kubectl apply -f ~/fmgNodePort.yaml && 

#fmgip=$(kubectl get pod virt-launcher-fmg-xl8p5 -o jsonpath='{.status.podIP}')
pubip=$(curl -s ipinfo.io | jq -r '.ip')
echo please access via https://$pubip:$nodeport
echo deploymentcompleted
