function cfos_ping_1_1_1_1() {
workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $workernodes
do
cfospod=`kubectl get pod -l app=fos --field-selector spec.nodeName=$node | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod -l app=multitool01 --field-selector spec.nodeName=$node | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
echo $node
kubectl exec -it po/$cfospod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
    echo $node/$cfospod , cfos is able to reach 1.1.1.1
     continue
   else
     cfos is not able to reach 1.1.1.1, something wrong
     kubectl rollout restart ds fos-deployment
   fi
done
}

cfos_ping_1_1_1_1
