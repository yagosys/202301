#!/bin/bash
function restart_cfos_if_not_ready {
    node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    for nodeName in $node_list; do
            kubectl rollout status deployment multitool01-deployment
            cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
            multpod=`kubectl get pods -l app=multitool01 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`
            if  kubectl exec -it po/$multpod -- ping -c 1 1.1.1.1
            then
                echo " on $nodeName cfos is ready"
                break
            else
                kubectl rollout restart ds/fos-deployment
      	         kubectl rollout status ds/fos-deployment
            fi
    done
}

kubectl create -f multus-daemonset.yml
kubectl create -f nad_bridge_cni_10_0_200_cfosdefauultcni5.yaml
kubectl rollout status ds/kube-multus-ds -n kube-system
kubectl create -f dockersecret.yaml
kubectl create -f fos_license.yaml
kubectl create -f cfos_firewallpolicy.yaml
kubectl create -f app.yaml
kubectl rollout status deployment
kubectl create -f cfos_account.yaml
echo "sleep 10"
sleep 10
kubectl create -f cfos.yaml
echo "sleep 10"
sleep 10
kubectl rollout status ds/fos-deployment
restart_cfos_if_not_ready
echo "sleep 10"
sleep 10
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
