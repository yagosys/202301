- prereqs 
gcloud binary is required.  you will also need install kubectl by using `gcloud components install gke-gcloud-auth-plugin`. 
you can use any client machine to run this demo, but use *google cloud shell* is recommended as it is pre-configured to use google cloud. 


- generate your docker pull secret for download cFOS image 



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
./demo_multiple_nodes.shell.sh

```
- check the result

```
cd ./doc
./gen_doc.sh
https://github.com/yagosys/202301/tree/main/demo/gke/cfos_multus/doc/README.md
```

- clean up

```
./del_cluster.sh && ./del_networks.sh
```
