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
kubectl rollout restart deployment fos-deployment
deploymentReady
#after deployment, the cfos may not work. run checkcfosreadiness.sh to fix it
