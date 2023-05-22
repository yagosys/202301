#!/bin/bash
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $ping_dst   ]] && ping_dst="1.1.1.1"
# Get list of node names
node_list=$(kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

function deletepod {
for nodeName in $node_list; do
	echo $1
     while true ; do
        kubectl rollout status deployment multitool01-deployment
        cfospod=`kubectl get pods -l app=$cfos_label --field-selector spec.nodeName=$nodeName |    cut -d ' ' -f 1 | tail -n -1`
        multpod=`kubectl get pods -l app=$1 --field-selector spec.nodeName=$nodeName |   cut -d ' ' -f 1 | tail -n -1`
        result=$(kubectl exec -it po/$multpod -- curl -k  https://$ping_dst 2>&1 | grep -o 'decryption failed or bad record mac')
        if [ "$result" = "decryption failed or bad record mac" ]
        then
        echo "cfos is not ready, delete cfos pod"
        kubectl delete po/$cfospod
        else
                echo " on $nodeName cfos is ready"
                break

        fi
     done
done
}

deletepod "multitool01"
