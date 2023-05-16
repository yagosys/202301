#!/bin/bash
filename="./../47_create_gatekeeper_constraint_template.sh"

echo -e '- install gatekeeperv3 constraint template \n ' > "${filename}.md"

cat << EOF >> "${filename}.md"

in this template, include a session call targets. in the targets it use rego as policy engine language to parse the policy . 
we use repo function *http.send* to send API to cFOS. you only need deploy template once.  
EOF

echo -e '- paste below command to install gatekeeper constraint template\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"

command="kubectl get constrainttemplates -o yaml"

echo -e 'check constraint template\n' >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"


