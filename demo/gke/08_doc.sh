#!/bin/bash
filename="08_create_cfos_ds.sh"

echo '- create cfos role and service account' > "${filename}.md"

cat << EOF >> "${filename}.md"

We will create cFOS as DaemonSet, so each node will have single cFOS POD.
cFOS will be attached to net-attach-def CRD which was created earlier.
cFOS is configured as a ClusterIP service for restapi port.
cFOS will use annotation to attach to CRD.
k8s.v1.cni.cncf.io/networks means secondary network.
Default interface inside cFOS is net1.
cFOS will have fixed IP 10.1.200.252/32 which is the range of CRD cni configuration.
cFOS can also have a fixed mac address.
Linux capabilities like NET_ADMIN, SYS_AMDIN, NET_RAW are required for ping, sniff and syslog.
cFOS image will be pulled from Docker Hub with pull secret.
the cFOS in GKE by default will not have a default route , We will use cFOS static route to add an default route

EOF

echo '- paste below command to create cfos DaemonSet' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"



command='kubectl rollout status ds/fos-deployment && kubectl get pod -l app=fos'

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"



command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$nodeName\" -o jsonpath='{.items[*].metadata.name}') && kubectl exec -it po/\$podName -- ip route  && kubectl exec -t po/\$podName -- ip address"

echo 'check routing table and ip address' >> "${filename}.md"
echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"

echo 'check cfos license' >> "${filename}.md"
command="nodeName=\$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') && podName=\$(kubectl get pods -l app=fos --field-selector spec.nodeName=\"\$nodeName\" -o jsonpath='{.items[*].metadata.name}') && kubectl logs po/\$podName"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command" >> "${filename}.md"
echo '```' >> "${filename}.md"