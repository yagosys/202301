#!/bin/bash -x
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id  ]] && configmap_policy_id="300"

filename="./../12_ipstest.sh.shell.sh.gen.sh"

echo -e '- do a ips test on a target website\n' > "${filename}.md"

cat << EOF >> "${filename}.md"
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the IPS signature. if match the signature. cFOS can either block it or pass it with alert depends on the policy configured.

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it. 
you will exepct to see ips traffic log with matched firewall policy id to indicate which policy is in action.

EOF

echo -e '- paste below command to send malicous traffic from application pod\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod | grep $cfos_label | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/ips.0 | grep $configmap_policy_id  ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

