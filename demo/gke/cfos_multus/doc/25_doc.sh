#!/bin/bash
filename="./../25_delete_app.sh"

echo '- delete current appliation deployment ' > "${filename}.md"

cat << EOF >> "${filename}.md"

EOF

echo '- paste below command to delete ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


