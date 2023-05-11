- Preparation

before you can run this demo. you will need have a valid cFOS license and secret to pull cfos image.
you can use 

`generatecfoslicensefromvmlicense.sh`  to generate configmap which include valid cfos license from a cfos license file.

and 
`generatedockersecret.sh` to generate a secret from docker login config.json file

you can put the license file and secret file into  "$HOME/license/" folder 

for example
```
ls -l  $HOME/license/*.yaml
-rw-r--r-- 1 wandy wandy 4870 May  8 07:13 /home/wandy/license/dockerpullsecret.yaml
-rw-r--r-- 1 wandy wandy 9193 Apr 27 09:51 /home/wandy/license/fos_license.yaml
```

- RUN DEMO

```
source ./variable.sh
./demo_awslinux_macvlan.sh
```
