kubectl create -f net_10_1_128.yaml
kubectl create -f net_default_10_86_0.yaml
kubectl create -f 00_pv_pvc.yaml
kubectl create -f 01_cfos_account.yaml
kubectl create -f 03_cfos_defaultroute.yaml
kubectl create -f 04_cfosfirewallpolicy.yaml
kubectl create -f 05_cfos_dns.yaml
kubectl create -f cfosdeployment.yaml
kubectl create -f application.yaml

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

function ping_1_1_1_1() {

cfospod=`kubectl get pod | grep fos | grep -v terminat | cut -d ' ' -f 1 | tail -n -1`
multpod=`kubectl get pod | grep multitool01 |  grep -v terminat |  cut -d ' ' -f 1 | tail -n -1`

kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
     return 0
   else
     return 1
   fi
}

   ping_1_1_1_1
   result=$?
   if [ $result -eq 0 ] ; then
        echo cfos is able to reach 1.1.1.1
   else
        echo cfos is not reach 1.1.1.1, restart
        kubectl rollout restart deployment fos-deployment
        sleep 10
        deploymentReady
   fi

#after deployment, the cfos may not work. run checkcfosreadiness.sh to fix it
