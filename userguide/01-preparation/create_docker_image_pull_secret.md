please follow link below for detail how to pull image from private registry 
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

below is a quick sample of how to create a pull secret on docker private repository on a linux platform

- login into your docker account with docker login 

```
docker login

```

- locate the config.json file 

upon sucessful docker log, a config.json which include your credential will be saved on $home/.docker.

```
$home/.docker/config.json

```

- create secret with this config.json file

```
base64encodedsecret=$(echo config.json | base64)

```

create a yaml file for kubernetes to use  
replace the $base64encodedsecret with actual content.

```
#!/bin/bash

# Check if the file exists
if [ -f "$HOME/.docker/config.json" ]; then

  # Encode the file using base64
  base64encodedsecret=$(base64 < "$HOME/.docker/config.json")
  echo "found config.json" 
else 
  base64encodedsecret="replace this with your base64encodedsecret"
fi
# Create a YAML file with the secret
cat <<EOF >sample_docker_secret.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: myregistrykey
    data:
      .dockerconfigjson: $base64encodedsecret
    type: kubernetes.io/dockerconfigjson
EOF


```



