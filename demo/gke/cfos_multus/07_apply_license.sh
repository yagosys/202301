file="$HOME/license/dockerpullsecret.yaml"
[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"
file="$HOME/license/fos_license.yaml"
[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"

