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

function insert_snat_entry_if_not_exist {
	node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
	 for nodeName in $node_list; do
            cfospod=`kubectl get pods -l app=fos --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
	    if kubectl  exec -it po/$cfospod -- iptables -t nat -C  fcn_nat -o eth0 -j MASQUERADE
            then 
		    echo "snat exist, do nothing"
	    else   
		    echo "insert snat entry to eth0 to $cfospod in $nodeName"
		    kubectl exec -it po/$cfospod -- iptables -t nat -A fcn_nat -o eth0 -j MASQUERADE
           fi
	 done
}

function install_gatekeeperv3 {
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
}

eksctl create cluster -f EKSDemoConfigAWSLinux.yaml 
kubectl create -f multus-daemonset.yml
kubectl create -f nad_macvlan_cfosdefaultcni5_10_1_200_no_snat.yaml
kubectl rollout status ds/kube-multus-ds -n kube-system
sleep 10
kubectl create -f dockersecret.yaml
kubectl create -f fos_license.yaml
sleep 10
kubectl create -f app_with_custom_route.yaml
kubectl rollout status deployment
kubectl create -f cfos_account.yaml
echo "sleep 10"
sleep 10
kubectl create -f cfos.yaml
echo "sleep 10"
sleep 10
kubectl rollout status ds/fos-deployment
#insert_snat_entry_if_not_exist 
echo "sleep 10"
sleep 10
kubectl create -f ./policy/watchandupdatcfospodip.yaml
sleep 10
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done

