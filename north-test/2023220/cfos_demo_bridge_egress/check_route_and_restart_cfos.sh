function  deploymentReady() {
while true; do
  output=$(kubectl get pod)
  if echo "$output" | grep -q "fos-deployment.*1/1" && echo "$output" | grep -q "multitool01-deployment.*1/1"; then
    echo "Both pods are ready!"
    break
  fi
    sleep 5
done

}

deploymentReady

function cfos_ping_1_1_1_1() {

cfospod=`kubectl get pod | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`

kubectl exec -it po/$cfospod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
     return 0
   else
     return 1
   fi
}

function ping_1_1_1_1() {

cfospod=`kubectl get pod | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`

kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
     echo ping 1.1.1.1 is ok
     return 0
   else
     echo ping 1.1.1.1 is not reachable
     return 1
   fi
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
        kubectl rollout restart deployment fos-deployment
        sleep 10
        deploymentReady
	ping_1_1_1_1
   fi

#after deployment, the cfos may not work. run checkcfosreadiness.sh to fix it
