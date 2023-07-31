#!/bin/bash
filename="./../50_restart_app.sh"
[[ -z $app_deployment_label ]] && app_deployment_label="multitool01"

echo -e '- restart application deployment to trigger policymanager update addressgrp in cFOS ' > "${filename}.md"
cat << EOF >> "${filename}.md"
due to limitation of policymanager, it require pod ip change to trigger update addressgrp in cFOS, we can restar application pod, scale in, scale out etc to force pod IP change. 
you can use "kubectl logs -f po/policymanager" to check the log of policymanager 

EOF

echo -e '- paste below command to restart appliation DaemonSet \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl rollout status deployment $app_deployment_label-deployment"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
