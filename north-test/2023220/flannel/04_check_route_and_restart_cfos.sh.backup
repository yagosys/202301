function  deploymentReady() {
workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

for node in $workernodes
do
  echo $node
  output=`kubectl get pods --field-selector spec.nodeName=$node`

    if echo "$output" | grep -q "fos-deployment.*1/1" && echo "$output" | grep -q "multitool01-deployment.*1/1"; then
    echo "Both pods are ready!"
    continue
  fi
    sleep 5
done

}

deploymentReady

function cfos_ping_1_1_1_1() {
workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $workernodes
do
cfospod=`kubectl get pod -l app=fos --field-selector spec.nodeName=$node | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod -l app=multitool01 --field-selector spec.nodeName=$node | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
echo $node
kubectl exec -it po/$cfospod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
     continue
   else
     return 1
   fi
done
}

function ping_1_1_1_1() {

workernodes=$(kubectl get nodes -l 'kubernetes.io/role=worker' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for node in $workernodes
do
cfospod=`kubectl get pod -l app=fos --field-selector spec.nodeName=$node  |  grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod -l app=multitool01 --field-selector spec.nodeName=$node | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`
echo $node
kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
     echo ping 1.1.1.1 is ok
     continue
   else
     echo ping 1.1.1.1 is not reachable
     return 1
   fi
done
}

   cfos_ping_1_1_1_1
   result=$?
   if [ $result -eq 0 ] ; then
        echo cfos is able to reach 1.1.1.1
   else
        echo cfos is not reach 1.1.1.1, something wrong
	exit
   fi

   ping_1_1_1_1
   result=$?
   if [ $result -eq 0 ] ; then
        echo application pod  is able to reach 1.1.1.1
   else
        echo application pod  is not reach 1.1.1.1, restart cfos
        kubectl rollout restart ds fos-deployment
        sleep 10
        deploymentReady
	ping_1_1_1_1
   fi

