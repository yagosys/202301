#!/bin/bash
filename="./../27_webftest.sh"

echo '- do a web filter  test on a target website' > "${filename}.md"

cat << EOF >> "${filename}.md"
this time we ,use destination that not on match default route, for example "https://xoso.com.vn". this website will be classified by cFOS as Gambling that shall be blocked by default profile.

EOF

echo '- paste below command initial access to the target website ' >> "${filename}.md" 

echo '```' >> "${filename}.md"
cat $filename >> "${filename}.md"
echo '```' >> "${filename}.md"


echo '- check the result' >> "${filename}.md"


command="kubectl get pod | grep fos | awk '{print \$1}'  | while read line; do kubectl exec -t po/\$line -- tail  /data/var/log/log/webf.0 | grep 101  ; done"

echo '`' >> "${filename}.md"
echo "$command" >> "${filename}.md"
echo '`' >> "${filename}.md"
echo '```' >> "${filename}.md"
eval "$command"  >> "${filename}.md"
echo '```' >> "${filename}.md"

