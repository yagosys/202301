- precheck

make sure you have enugh storage space for hold fmg image file.  at least 20G space is required for pv to use

- install kubevirt 

```
#!/bin/bash -xe
export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | sort -r | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
echo $VERSION
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml

kubectl rollout status deployment -n kubevirt && 
kubectl rollout status ds -n kubevirt
```

- install virtcl client  
```
#!/bin/bash -xe 
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
chmod +x virtctl
sudo install virtctl /usr/local/bin
```

- disable kvm if kvm is not avaiable

```
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
```

- install storageclass from s3  and make it default 

```
#install localhost storageclass
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```


- intall data importor 
```
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml && 
kubectl -n cdi scale deployment/cdi-operator --replicas=1
```

- install crd for cdi 
```
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml

kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi && 

kubectl -n cdi get pods

```
- create fmg datavolume

```
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "fmg"
spec:
  source:
    http:
      url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmg.qcow2" # S3 or GCS
  pvc:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: "5000Mi"

```
- create fgt vm 


```
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
    spec:
      domain:
        cpu:
          cores: 1
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
            memory: 1000M
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
```
- modify fmg ip

```
virtctl console fmg
```

username admin
password Welcome.123

config system interface
edit port1
set ip xxxx

- ssh into fmg

```
virctl ssh admin@fmg
```
