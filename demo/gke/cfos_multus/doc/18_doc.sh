#!/bin/bash
filename="./../18_create_policy_manager.sh"

echo -e '- create an POD to update POD source IP to cFOS\n ' > "${filename}.md"

cat << EOF >> "${filename}.md"
POD IPs are keep changing due to scale in/out or reborn , deleting etc for various reason, we need to keep update the POD ip address to cFOS address group. 
we create a POD dedicated for this. this POD keep running a background proces which update the application POD's IP  that has annoation to net-attach-def *$app_nad_annotation"* to cFOS via cFOS restful API. 
the API call to cFOS can use either cFOS dns name or cFOS node IPs. if cFOS use shared storage for configuration, then use dns name is proper way, otherwise, we will need to update each cFOS POD directly via CFOS POD ip address. the policy_manager by default using cFOS POD ip address. 
the policy_manager also create  firewallpolicy for target application unless the policy has already createdby gatekeeper. this is only for demo purpose.  the firewall policy created on cFOS has fixed policyID=200
the policy_manager pod use image from *interbeing/kubectl-cfos:gke_demo_v1*
the source code of this image is under policymanager/
build.sh  Dockerfile  script.sh
you can build by yourself. 
EOF


echo -e '- paste below command to create policy_manager \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod policymanager && kubectl exec -it po/policymanager -- curl -X GET \"http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp\""

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '\n' >> "${filename}.md"
echo -e '```' >> "${filename}.md"

