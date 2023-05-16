#!/bin/bash
filename="./../50_restart_app.sh"

echo '- restart application deployment to trigger policymanager update addressgrp in cFOS ' > "${filename}.md"
cat << EOF >> "${filename}.md"
due to limitation of policymanager, it require pod ip change to trigger update addressgrp in cFOS, we can restar application pod, scale in, scale out etc to force pod IP change. 
you can use "kubectl logs -f po/policymanager" to check the log of policymanager 

EOF

echo '- paste below command to restart appliation DaemonSet ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl rollout status deployment multitool01-deployment"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"
