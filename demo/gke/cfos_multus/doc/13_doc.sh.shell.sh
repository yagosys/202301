#!/bin/bash
filename="./../13_webftest.sh.shell.sh.gen.sh"
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"

echo -e '- do a web filter  test on a target website \n' > "${filename}.md"

cat << EOF >> "${filename}.md"
it is very common that a malicous POD can geneate some malicous traffic targeting external network or VM or physical machine in custmer network. those traffic are often encrypted , when these traffic reach cFOS, cFOS can decrpyt the traffic and look into the domain name of target website. it the target website belong to category that suppose to be blocked, cFOS will block it. the database of maclious website will always updated to the latest from fortiguard service. 

we will generate some malicous traffic from application POD targeting a testing website. cFOS will block the traffic and log it.
you will expect to see web filter log with matched policy id to indicate which firewall policy is in action
EOF

echo -e '- paste below command initial access to the target website \n' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod | grep $cfos_label | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep $configmap_policy_id ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

