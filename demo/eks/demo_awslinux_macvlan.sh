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


function do_demo {

eksctl create cluster -f EKSDemoConfigAWSLinux.yaml &&
kubectl create -f multus-daemonset.yml
kubectl create -f nad_macvlan_cfosdefaultcni5_10_1_200_no_snat.yaml
kubectl rollout status ds/kube-multus-ds -n kube-system
sleep 10
kubectl create -f $dockersecretfile
kubectl create -f $cfoslicensefile
kubectl create -f cfos_account.yaml
echo "sleep 10"
sleep 10
kubectl create -f cfos.yaml
echo "sleep 10"
sleep 10
kubectl rollout status ds/fos-deployment
kubectl create -f app_with_custom_route.yaml
kubectl create -f test_app_testtest.yaml
kubectl rollout status deployment
echo "sleep 10"
sleep 10
kubectl create -f ./policy/watchandupdatcfospodip.yaml
sleep 15
kubectl get pod | grep multi | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
kubectl get pod | grep testtest | grep -v termin  | awk '{print $1}'  | while read line; do kubectl exec -t po/$line -- ping -c1 1.1.1.1 ; done
}

function do_demo_new {
echo "start"
./00-create_eks_cluster.sh ;  
./01_create_multus_ds_v393.sh &&  \
./02_create_nad.sh && \
./03_deploy_cfos_license_and_cfos_pull_secret.sh && \
./04_create_cfos_account.sh && \
./05_create_cfos_ds_service.sh && \
./06_create_deployment_app.sh && \
./07_create_deployment_new_test.sh && \
./08_create_policy_manager.sh && \
sleep 5 && \
./09_pingtest.sh && \
./09_2_check_cfos_health.sh && \
./10_webfilter.sh
}

dockersecretfile="$HOME/license/dockerpullsecret.yaml"
cfoslicensefile="$HOME/license/fos_license.yaml"

if [[ -f "$dockersecretfile" ]] && [[ -f "$cfoslicensefile" ]]; then
do_demo_new
else
echo need dockersecret and cfos license to continue
fi


