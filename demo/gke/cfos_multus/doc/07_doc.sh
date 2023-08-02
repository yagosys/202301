#!/bin/bash
filename="./../07_apply_license.sh"

echo -e '- create cfos licenset\n' > "${filename}.md"

cat << EOF >> "${filename}.md"

here we create cfos license with fortigate VM license and generate configmap for cfos to fetch license
EOF

echo -e '- paste below command to create and apply license \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl  get cm fos-license" 

echo -e "\`$command\`" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
echo -e "$($command)"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"



