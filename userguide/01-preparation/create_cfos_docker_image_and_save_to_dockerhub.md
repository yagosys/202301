- Download cFOS firemware , either X64 version or ARM version. use Docker iamge for run in kubernetes.

```
"FOS_X64_DOCKER-v7-build0232-FORTINET.tar.gz" 
``
- create image from cFOS firmware 
cFOS firmware is  a tar archive that contains all the layers and metadata required to recreate the image. You can  use the docker load command to load that tar archive back into Docker, which recreates the image on your system. 

```
docker load < FOS_X64_DOCKER-v7-build0232-FORTINET.tar.gz

```
- to use image on kubernetes. we need to upload it to a repository. tag the image before upload to repository
below is an example tag it with my docker.io account and repository (fos). the version is X64v7build0232

```
docker tag fos:latest interbeing/fos:X64v7build0232
```
-  push image to my private repository

```
docker push interbeing/fos:X64v7build0232

```

- to use it in kubernetes. you will need to create a pull secret to pull it from docker.
