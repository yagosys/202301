to run cfos, a copy for cfos license is required. 
the cfos license can either use configmap or import into cfos with cfos cli. use configmap allow you to load license before install cfos.

the configmap of license has format below
do not forgot the "|" after the license: field. which means all the space and new line character in the text will be excluded.

```
cat <<EOF | >sample_cfos_license_configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: fos-license
    labels:
        app: fos
        category: license
data:
    license: |
     -----BEGIN FGT VM LICENSE-----
     paste your vm license here
     -----END FGT VM LICENSE-----
EOF
```
