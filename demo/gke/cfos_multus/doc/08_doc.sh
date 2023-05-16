#!/bin/bash
filename="./../08_create_cfos_account.sh"

echo -e '- create cfos role and service account\n' > "${filename}.md"

cat << EOF >> "${filename}.md"

cfos will require to read configmap permission to get license and also cfos will require read-secrets permission to get secret to pull cfos image

EOF

echo -e '- paste below command to create cfos role and service account' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"



command='kubectl get rolebinding read-configmaps && kubectl get rolebinding read-secrets -o yaml'

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"


