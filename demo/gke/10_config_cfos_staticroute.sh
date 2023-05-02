file="configmapstaticroute.yml"
cat << EOF > $file
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgstaticroute
  labels:
      app: fos
      category: config
data:
  type: partial
  config: |-
    config router static
      edit "1"
          set dst 0.0.0.0/0
          set gateway 10.140.0.1
          set device "eth0"
      next
    end
EOF
kubectl create -f $file 
