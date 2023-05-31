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

```

- install virtcl client  

```
#!/bin/bash -xe 
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64
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
kubectl rollout status deployment/local-path-provisioner  -n local-path-storage
```


- intall data importor 
```
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml && 
kubectl -n cdi scale deployment/cdi-operator --replicas=1 && 
kubectl -n cdi rollout status deployment/cdi-operator 

```

- install crd for cdi 
```
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi --timeout=600s && 
kubectl -n cdi get pods

```
- create fmg datavolume

```
kubectl create -f - << EOF
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
EOF

```
- create fgt vm 


```
kubectl create -f - << EOF
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
EOF
```
- check the import status
import-fmg is one-time task pod. once import task compelted, it will be removed. 

```
kubectl  logs -f po/importer-fmg
...
I0527 06:44:06.687431       1 qemu.go:258] 99.01
I0527 06:44:09.371200       1 data-processor.go:282] New phase: Resize
W0527 06:44:09.376387       1 data-processor.go:361] Available space less than requested size, resizing image to available space 4954521600.
I0527 06:44:09.376488       1 data-processor.go:372] Expanding image size to: 4954521600
I0527 06:44:09.382986       1 data-processor.go:288] Validating image
I0527 06:44:09.388563       1 data-processor.go:282] New phase: Complete
I0527 06:44:09.388751       1 importer.go:212] Import Complete
```
if sucess, the pvc will be created.

```
ubuntu@ip-10-0-1-100:~$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   REASON   AGE
pvc-f673b6a8-c8fe-443b-b6d1-7903576ec906   5000Mi     RWO            Delete           Bound    default/fmg   local-path              2m30s
ubuntu@ip-10-0-1-100:~$ kubectl get pvc 
NAME   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
fmg    Bound    pvc-f673b6a8-c8fe-443b-b6d1-7903576ec906   5000Mi     RWO            local-path     3m48s
```

- check the vm created 
```
ubuntu@ip-10-0-1-100:~$ kubectl  get pod -o wide
NAME                      READY   STATUS    RESTARTS   AGE    IP            NODE            NOMINATED NODE   READINESS GATES
virt-launcher-fmg-thk7x   1/1     Running   0          118s   10.244.1.18   ip-10-0-2-200   <none>           1/1
ubuntu@ip-10-0-1-100:~$ kubectl get vm
NAME   AGE     STATUS    READY
fmg    3m26s   Running   True
```
virtctl console fmg

```
ubuntu@ip-10-0-1-100:~$ kubectl get vm
NAME   AGE     STATUS    READY
fmg    5m15s   Running   True
ubuntu@ip-10-0-1-100:~$ virtctl console fmg
Successfully connected to fmg console. The escape sequence is ^]
                                                                DVM DB upgrade failed!
initd - error in blocking task: cdbupgrade(/bin/cdbupgrade), pid=683, exit=255.




FMG-VM64 login: admin
Password: Welcome.123
FMG-VM64 # 
FMG-VM64 # 
```

- change ip address
```
FMG-VM64 # config system interface 

(interface)# edit port1

(port1)# set ip 10.244.1.18/24

(port1)# end

FMG-VM64 # get system interface 
== [ port1 ]
name: port1    status: enable    ip: 10.244.1.18 255.255.255.0   speed: auto    
== [ port2 ]
```
- ssh into fmg

```
ubuntu@ip-10-0-1-100:~$ virtctl ssh admin@fmg
The authenticity of host 'vmi/fmg.default:22 (10.0.1.100:6443)' can't be established.
ECDSA key fingerprint is SHA256:mN+lfm/Je5irdDI0saNg8XYNyg7C0a0QxUf4JSYlFGo.
Are you sure you want to continue connecting (yes/no)? yes
admin@vmi/fmg.default's password: 
FMG-VM64 # 

```
- deploy test pod


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tool
  template:
    metadata:
      labels:
        app: tool
    spec:
      containers:
      - name: network-multitool
        #image: praqma/network-multitool
        image: nicolaka/netshoot
        command: ["/bin/bash"]
        args: ["-c", "while true; do ping localhost; sleep 60;done"]
        securityContext:
          privileged: true
``
