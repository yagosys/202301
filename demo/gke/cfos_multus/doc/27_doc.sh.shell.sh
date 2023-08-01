#!/bin/bash
[[ -z $cfos_label ]] && cfos_label="fos"
filename="./../27_webftest.sh.shell.sh.gen.sh"
policy_id="101"
[[ -z $internet_webf_url ]] && internet_webf_url="https://xoso.com.vn"
echo -e '- do a web filter  test on a target website\n' > "${filename}.md"

cat << EOF >> "${filename}.md"
this time we ,use destination that not on match default route, for example $internet_webf_url  this website will be classified by cFOS as Gambling that shall be blocked by default profile.

EOF

echo -e '- paste below command initial access to the target website ' >> "${filename}.md" 

echo -e '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo -e '```' >> "${filename}.md"


echo -e '- check the result\n' >> "${filename}.md"


command="kubectl get pod | grep $cfos_label | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep policyid="$policy_id"  ; done"

echo -e '`' >> "${filename}.md"
echo -e "$command" >> "${filename}.md"
echo -e '`' >> "${filename}.md"
echo -e '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo -e '```' >> "${filename}.md"

