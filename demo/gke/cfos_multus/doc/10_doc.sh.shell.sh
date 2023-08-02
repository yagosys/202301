#!/bin/bash -x
filename="./../10_config_cfos_firewallpolicy.sh.shell.sh.yml.sh"
source variable.sh
echo -e '- create configmap for cfos to get firewall policy configuration/n ' > "${filename}.md"

cat << EOF >> "${filename}.md"
cfos can be configured use cFOS shell, kubernetes configmap and restApi. here we use configmap to config cFOS
there is an issue in this version, the configuration applied via configmap will not take effect until you restart cFOS DS.
the firewall policy has policy id set to $configmap_policy_id and source address set to any. once configmap created, cFOS will read the configmap and apply the policy. you can chech the log on cFOS to verify this.
delete configmap will not delete the policy on cFOS. you can also edit the policy in configmap use *kubectl edit cm foscfgfirewallpolicy* to update the policy.

EOF

echo -e '- paste below command to create configmap that include firewall policy configuration/n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"



command='kubectl get configmap foscfgfirewallpolicy -o yaml'

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"




echo -e 'check cfos log for retrive config from configmap' >> "${filename}.md"

command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && for node in \$nodeName; do podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$node\" -o jsonpath='{.items[*].metadata.name}') ; kubectl logs po/\$podName ; done"
echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo -e '```' >> "${filename}.md"
