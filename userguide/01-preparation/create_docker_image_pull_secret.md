please follow link below for detail how to pull image from private registry 
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

below is a quick sample of how to create a pull secret on docker private repository

on linux platform

login into your docker account with docker login 

```
docker login

```

you shall get a docker config file 

```
$home/.docker/config.json
```

create secret with this config.json file

$base64encodedsecret= `echo config.json | base64`

```
create a yaml file 

```
apiVersion: v1
kind: Secret
metadata:
  name: myregistrykey
data:
  .dockerconfigjson: $base64encodedsecret
type: kubernetes.io/dockerconfigjson
```



