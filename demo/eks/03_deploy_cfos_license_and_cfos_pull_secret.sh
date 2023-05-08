[[ $dockersecretfile=="" ]] && dockersecretfile="$HOME/license/dockerpullsecret.yaml"
[[ $cfoslicensefile=="" ]] && cfoslicensefile="$HOME/license/fos_license.yaml"

if [[ -f "$dockersecretfile" ]] && [[ -f "$cfoslicensefile" ]]; then
kubectl create -f $dockersecretfile 
kubectl create -f $cfoslicensefile
else
echo need dockersecret and cfos license to continue
fi
