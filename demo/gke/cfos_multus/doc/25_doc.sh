#!/bin/bash
filename="./../25_delete_app.sh"

echo -e '- delete current appliation deployment\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"

EOF

echo -e '- paste below command to delete\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


