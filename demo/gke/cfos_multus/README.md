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
WARNING! Your password will be stored unencrypted in /home/wandy/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

wandy@cloudshell:~/github-yagosys/202301/demo/gke/cfos_multus (cfos-384323)$ ./generatedockersecret.sh $HOME/.docker/config.json
dockerpullsecret.yaml created
```

- generate cFOS license secret 
```
wandy@cloudshell:~/github-yagosys/202301/demo/gke/cfos_multus (cfos-384323)$ ./generatecfoslicensefromvmlicense.sh FGVMULTM23000010.lic
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
