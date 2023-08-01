#!/bin/bash
filename="./../23_webftest.sh.shell.sh.gen.sh"
[[ -z $cfos_label ]] && cfos_label="fos"
policy_id="101"
echo -e '- do a web filter  test on a target website\n' > "${filename}.md"

cat << EOF >> "${filename}.md"
same to web fitler traffic
EOF

echo -e '- paste below command initial access to the target website\n ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod | grep $cfos_label | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep policyid=$policy_id  ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

