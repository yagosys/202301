- generate your docker pull secret for download cFOS image 


*please use google clud shell to run demo.*

the document for ste by step demo is ./doc/README.md

- generate docker pull secret

```
(cfos-384323)$ docker logn
docker: 'logn' is not a docker command.
See 'docker --help'
(cfos-384323)$ docker login
Authenticating with existing credentials...
Login Succeeded

(cfos-384323)$ ./generatedockersecret.sh $HOME/.docker/config.json
dockerpullsecret.yaml created
```

- generate cFOS license secret 
```
(cfos-384323)$ ./generatecfoslicensefromvmlicense.sh FGVMULTM23000010.lic
cfos_license.yaml created

```
- how to run 

```
source ./variable
./demo_multiple_nodes.sh

```

- clean up

```
./del_cluster.sh && ./del_networks.sh
```
