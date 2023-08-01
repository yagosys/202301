#!/bin/bash
filename="./../07_apply_license.sh"

echo -e '- apply cfos license \n' > "${filename}.md"

cat << 'EOF' >> "${filename}.md"

if license have not applied yet. you can create and apply icense for cfos here. the license is in configmap format
- generate docker pull secret

```
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

EOF

echo -e '- paste below command to create cfos license and cfos image pull secret \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get cm fos-license"

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

command="kubectl get secret"

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"
