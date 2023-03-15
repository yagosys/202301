function install_flannel_with_default_config {

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

}

function install_multus_with_default_auto_conf {

sudo crictl pull ghcr.io/k8snetworkplumbingwg/multus-cni:stable
cd /home/ubuntu
git clone https://github.com/intel/multus-cni.git
cat /home/ubuntu/multus-cni/deployments/multus-daemonset.yml | kubectl apply -f -

}

function create_config_for_cfos {
cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cfosdata
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1.1Gi
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /home/ubuntu/data/pv0001
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cfosdata
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: default
  name: configmap-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-configmaps
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: configmap-reader
  apiGroup: ""
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
   namespace: default
   name: secrets-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: secrets-reader
  apiGroup: ""

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgstaticdefaultroute
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config router static
       edit "1"
           set gateway 169.254.1.1
           set device "eth0"
       next
    end

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgfirewallpolicy
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config firewall policy
           edit "3"
               set utm-status enable
               set name "pod_to_internet_HTTPS_HTTP"
               set srcintf any
               set dstintf eth0
               set srcaddr all
               set dstaddr all
               set service HTTPS HTTP PING DNS
               set ssl-ssh-profile "deep-inspection"
               set ips-sensor "default"
               set webfilter-profile "default"
               set av-profile "default"
               set nat enable
               set logtraffic all
           next
       end

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgdns
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config system dns
      set primary 10.96.0.10
      set secondary 10.0.0.2
    end

EOF
}

function create_net_att_def_cfosdefaultcni5 {
cat << EOF | kubectl apply -f -
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: cfosdefaultcni5
spec:
  config: |-
    {
      "cniVersion": "0.3.1",
      "name": "cfosdefaultcni5",
      "type": "bridge",
      "bridge": "cni5",
      "isGateway": true,
      "ipMasq": false,
      "hairpinMode": true,
      "ipam": {
          "type": "host-local",
          "routes": [
              { "dst": "10.96.0.0/12","gw": "10.1.128.1" },
              { "dst": "10.0.0.2/32", "gw": "10.1.128.1" }
          ],
          "ranges": [
              [{ "subnet": "10.1.128.0/24" }]
          ]
      }
    }
EOF
}

function create_cfos_ds_deployment { 

cat << EOF | kubectl apply -f - 
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
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "ips": [ "10.1.128.252/32" ], "mac": "CA:FE:C0:FF:00:02" } ]'
    spec:
      containers:
      - name: fos
        image: interbeing/fos:v7231x86
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
        #nfs:
        #  server: 10.0.1.100
        #  path: /home/ubuntu/data
        #  readOnly: no
        persistentVolumeClaim:
          claimName: cfosdata
EOF
}


function create_demo_application {
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool01-deployment
  labels:
      app: multitool01
spec:
  replicas: 3
  selector:
    matchLabels:
        app: multitool01
  template:
    metadata:
      labels:
        app: multitool01
      annotations:
        k8s.v1.cni.cncf.io/networks: '[ { "name": "cfosdefaultcni5",  "default-route": ["10.1.128.252"]  } ]'
    spec:
      containers:
        - name: multitool01
          #image: wbitt/network-test
          image: praqma/network-multitool
            #image: nginx:latest
          imagePullPolicy: Always
            #command: ["/bin/sh","-c"]
          args:
            - /bin/sh
            - -c
            - /usr/sbin/nginx -g "daemon off;"
          securityContext:
            capabilities:
              add: ["NET_ADMIN","SYS_ADMIN","NET_RAW"]
          #  privileged: true
EOF

}

function restart_ds_fos_deployment {
kubectl rollout restart ds fos-deployment
}

install_flannel_with_default_config
install_multus_with_default_auto_conf
create_config_for_cfos
create_net_att_def_cfosdefaultcni5
create_cfos_ds_deployment
create_demo_application
restart_ds_fos_deployment
