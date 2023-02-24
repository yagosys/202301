function cfos_ping_1_1_1_1() {
workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $workernodes
do
cfospod=`kubectl get pod -l app=fos --field-selector spec.nodeName=$node | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod -l app=multitool01 --field-selector spec.nodeName=$node | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$cfospod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
    echo $node/$cfospod , cfos is able to reach 1.1.1.1
     continue
   else
     echo cfos is not able to reach 1.1.1.1, something wrong
   fi
done
}

function app_ping_1_1_1_1() {
workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $workernodes
do
cfospod=`kubectl get pod -l app=fos --field-selector spec.nodeName=$node | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod -l app=multitool01 --field-selector spec.nodeName=$node | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
    echo $node/$cfospod , $multpod is able to reach 1.1.1.1
     continue
   else
    echo $node/$multpod is not able to reach 1.1.1.1, something wrong
    echo restart cfos ds
     kubectl rollout restart ds fos-deployment
     kubectl rollout status ds/fos-deployment
   fi
done
}
cfos_ping_1_1_1_1
app_ping_1_1_1_1
