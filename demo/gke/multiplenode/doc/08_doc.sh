#!/bin/bash
filename="./../08_create_cfos_account.sh"

echo '- create cfos role and service account' > "${filename}.md"

cat << EOF >> "${filename}.md"

cfos will require to read configmap permission to get license and also cfos will require read-secrets permission to get secret to pull cfos image

EOF

echo '- paste below command to create cfos role and service account' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"



command='kubectl get rolebinding read-configmaps && kubectl get rolebinding read-secrets -o yaml'

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"


