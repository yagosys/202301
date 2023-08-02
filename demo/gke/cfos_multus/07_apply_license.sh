[[ -z $cfos_license_input_file ]] && cfos_license_input_file="FGVMULTM23000044.lic"
[[ -f $cfos_license_input_file ]] ||  echo $cfos_license_input_file does not exist
mkdir -p $HOME/license
file="$HOME/license/cfos_license.yaml"
licensestring=$(sed '1d;$d' $cfos_license_input_file | tr -d '\n')
cat <<EOF >$file
apiVersion: v1
kind: ConfigMap
metadata:
    name: fos-license
    labels:
        app: fos
        category: license
data:
    license: |
     -----BEGIN FGT VM LICENSE-----
     $licensestring
     -----END FGT VM LICENSE-----
     
EOF

#file="$HOME/license/dockerpullsecret.yaml"
#[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"
file="$HOME/license/cfos_license.yaml"
[ -e $file ] && kubectl create -f $file || echo "$file  does not exist"

