- install multus cni 



We need to install multus CNI for route traffic from application POD to cFOS POD
by default, GKE come with default cni which is use ptp binary with host-local ipam. the default cni config has name "10-containerd-net.conflist". when we install multus, 
the default multus config will use *"--multus-conf-file=auto"*, with this option. multus will automatically create 00-multus.conf file with delegate to default 10-containerd-net.conflist. in this demo. we use default behavior. 
we  need to change default multus config *path: /home/kubernetes/bin* . this is because GKE only grant this directory with writ permission.
each worker node will have one multus POD installed. 
- paste below command to install multus CNI  
```
file="multus_auto.yml"
multusconfig="auto"
multus_bin_hostpath="/home/kubernetes/bin"
cat << EOF > $file
# Note:
#   This deployment file is designed for 'quickstart' of multus, easy installation to test it,
#   hence this deployment yaml does not care about following things intentionally.
#     - various configuration options
#     - minor deployment scenario
#     - upgrade/update/uninstall scenario
#   Multus team understand users deployment scenarios are diverse, hence we do not cover
#   comprehensive deployment scenario. We expect that it is covered by each platform deployment.
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: network-attachment-definitions.k8s.cni.cncf.io
spec:
  group: k8s.cni.cncf.io
  scope: Namespaced
  names:
    plural: network-attachment-definitions
    singular: network-attachment-definition
    kind: NetworkAttachmentDefinition
    shortNames:
    - net-attach-def
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          description: 'NetworkAttachmentDefinition is a CRD schema specified by the Network Plumbing
            Working Group to express the intent for attaching pods to one or more logical or physical
            networks. More information available at: https://github.com/k8snetworkplumbingwg/multi-net-spec'
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this represen
                tation of an object. Servers should convert recognized schemas to the
                latest internal value, and may reject unrecognized values. More info:
                https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this
                object represents. Servers may infer this from the endpoint the client
                submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: 'NetworkAttachmentDefinition spec defines the desired state of a network attachment'
              type: object
              properties:
                config:
                  description: 'NetworkAttachmentDefinition config is a JSON-formatted CNI configuration'
                  type: string
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: multus
rules:
  - apiGroups: ["k8s.cni.cncf.io"]
    resources:
      - '*'
    verbs:
      - '*'
  - apiGroups:
      - ""
    resources:
      - pods
      - pods/status
    verbs:
      - get
      - update
  - apiGroups:
      - ""
      - events.k8s.io
    resources:
      - events
    verbs:
      - create
      - patch
      - update
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: multus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: multus
subjects:
- kind: ServiceAccount
  name: multus
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: multus
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: multus-cni-config
  namespace: kube-system
  labels:
    tier: node
    app: multus
data:
  # NOTE: If you'd prefer to manually apply a configuration file, you may create one here.
  # In the case you'd like to customize the Multus installation, you should change the arguments to the Multus pod
  # change the "args" line below from
  # - "--multus-conf-file=auto"
  # to:
  # "--multus-conf-file=/tmp/multus-conf/07-multus.conf"
  # Additionally -- you should ensure that the name "07-multus.conf" is the alphabetically first name in the
  # /etc/cni/net.d/ directory on each node, otherwise, it will not be used by the Kubelet.
  cni-conf.json: |
    {
      "name": "multus-cni-network",
      "type": "multus",
      "capabilities": {
        "portMappings": true
      },
      "delegates": [
        {
          "cniVersion": "0.3.1",
          "name": "k8s-pod-network",
          "plugins": [
            {
              "type": "ptp",
              "mtu": 1460,
              "ipam": {
                "type": "host-local",
                "subnet": "10.140.0.0/24",
                "gateway": "10.140.0.1",
                "routes": [
                  {
                    "dst": "10.144.0.0/20"
                  },
                  {
                    "dst": "10.140.0.0/14"
                  },
                  {
                    "dst": "0.0.0.0/0"
                  }
                 ]
            }
          },
              {
                "type": "portmap",
                "capabilities": {
                  "portMappings": true
                }
              }
          ]
        }
      ],
      "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig"
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-multus-ds
  namespace: kube-system
  labels:
    tier: node
    app: multus
    name: multus
spec:
  selector:
    matchLabels:
      name: multus
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        tier: node
        app: multus
        name: multus
    spec:
      hostNetwork: true
      tolerations:
      - operator: Exists
        effect: NoSchedule
      - operator: Exists
        effect: NoExecute
      serviceAccountName: multus
      containers:
      - name: kube-multus
        image: ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
        command: ["/entrypoint.sh"]
        args:
        - "--multus-conf-file=$multusconfig"
        #- "--multus-conf-file=auto"
        - "--cni-version=0.3.1"
        resources:
          requests:
            cpu: "100m"
            memory: "50Mi"
          limits:
            cpu: "100m"
            memory: "50Mi"
        securityContext:
          privileged: true
        volumeMounts:
        - name: cni
          mountPath: /host/etc/cni/net.d
        - name: cnibin
          mountPath: /host/opt/cni/bin
        - name: multus-cfg
          mountPath: /tmp/multus-conf
      initContainers:
        - name: install-multus-binary
          image: ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.3
          command:
            - "cp"
            - "/usr/src/multus-cni/bin/multus"
            - "/host/opt/cni/bin/multus"
          resources:
            requests:
              cpu: "10m"
              memory: "15Mi"
          securityContext:
            privileged: true
          volumeMounts:
            - name: cnibin
              mountPath: /host/opt/cni/bin
              mountPropagation: Bidirectional
      terminationGracePeriodSeconds: 10
      volumes:
        - name: cni
          hostPath:
            path: /etc/cni/net.d
        - name: cnibin
          hostPath:
            path: $multus_bin_hostpath
        - name: multus-cfg
          configMap:
            name: multus-cni-config
            items:
            - key: cni-conf.json
              path: 07-multus.conf
EOF
kubectl create -f $file
kubectl rollout status ds/kube-multus-ds -n kube-system
```
- check the result

`kubectl rollout status ds/kube-multus-ds -n kube-system`
`kubectl logs ds/kube-multus-ds -c kube-multus -n kube-system)`
 you shall see output 
```
daemon set "kube-multus-ds" successfully rolled out
2023-08-01T11:18:53+00:00 Generating Multus configuration file using files in /host/etc/cni/net.d...
2023-08-01T11:18:53+00:00 Using MASTER_PLUGIN: 10-containerd-net.conflist
2023-08-01T11:18:54+00:00 Nested capabilities string: "capabilities": {"portMappings": true},
2023-08-01T11:18:54+00:00 Using /host/etc/cni/net.d/10-containerd-net.conflist as a source to generate the Multus configuration
```
