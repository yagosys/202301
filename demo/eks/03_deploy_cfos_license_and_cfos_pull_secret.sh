[[ -z $dockersecretfile ]] && dockersecretfile="$HOME/license/dockerpullsecret.yaml"
[[ -z $cfoslicensefile ]] && cfoslicensefile="$HOME/license/fos_license.yaml"

if [[ -f "$dockersecretfile" ]] && [[ -f "$cfoslicensefile" ]]; then
kubectl create -f $dockersecretfile  
kubectl get secret
kubectl create -f $cfoslicensefile 
kubectl get cm
else
echo need dockersecret and cfos license to continue
fi
