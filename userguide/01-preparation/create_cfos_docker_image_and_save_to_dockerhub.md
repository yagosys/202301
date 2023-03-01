1. Download cFOS firemware , either X64 version or ARM version  , it shall have name like for X64 Version

"FOS_X64_DOCKER-v7-build0232-FORTINET.tar.gz" 

2. Build docker image use docker cli or podman

```
docker load < FOS_X64_DOCKER-v7-build0232-FORTINET.tar.gz

```
3. tag image

```
docker tag fos:latest interbeing/fos:X64v7build0232
```
4. push image to private repository

```
docker push interbeing/fos:X64v7build0232

```

