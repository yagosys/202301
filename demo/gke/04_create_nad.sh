file="nad.yml"
cat << EOF > $file 
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
      "ipMasq": true,
      "hairpinMode": true,
      "ipam": {
          "type": "host-local",
          "routes": [
              { "dst": "1.2.3.4/32", "gw": "10.1.200.1" }
          ],
          "ranges": [
              [{ "subnet": "10.1.200.0/24" }]
          ]
      }
    }
EOF
kubectl create -f $file && kubectl get net-attach-def

