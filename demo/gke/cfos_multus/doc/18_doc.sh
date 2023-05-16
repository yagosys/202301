#!/bin/bash
filename="./../18_create_policy_manager.sh"

echo '- create an POD to update POD source IP to cFOS ' > "${filename}.md"

cat << EOF >> "${filename}.md"
POD IPs are keep changing due to scale in/out or reborn , deleting etc for various reason, we need to keep update the POD ip address to cFOS address group. 
we create a POD dedicated for this. this POD keep running a background proces which update the application POD's IP  that has annoation to net-attach-def "cfosapp" to cFOS via cFOS restful API. 
the API call to cFOS can use either cFOS dns name or cFOS node IPs. if cFOS use shared storage for configuration, then use dns name is proper way, otherwise, we will need to update each cFOS POD directly via CFOS POD ip address. the policy_manager by default using cFOS POD ip address. 

the policy_manager pod use image from *interbeing/kubectl-cfos:gke_demo_v1*
the source code of this image is under policymanager/
build.sh  Dockerfile  script.sh
you can build by yourself. 
EOF


echo '- paste below command to create policy_manager ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"

command="kubectl get pod policymanager && kubectl exec -it po/policymanager -- curl -X GET \"http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp\""

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '\n' >> "${filename}.md"
echo '```' >> "${filename}.md"

