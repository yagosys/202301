
function waitforMultusReady {
	while true; do
             if kubectl get ds kube-multus-ds -n kube-system -o yaml | grep -q "updatedNumberScheduled: 1" ; then
               echo "multus daemonSet Ready"
               break
             else
               echo "multus daemonSet has not ready yet"
               sleep 1
             fi
        done
}

sudo cp /etc/cni/net.d/100-crio-bridge.conf ./misc/100-crio-bridge.conf.ori
sudo cp ./misc/100-crio-bridge.conf.cfos /etc/cni/net.d/100-crio-bridge.conf
kubectl rollout restart daemonset kube-multus-ds -n kube-system
waitforMultusReady
echo wait another 15 second for crio completely ready. otherwise, the default route will not be removed, I do not know why, just wait 15 seconds more.
sleep 15
kubectl apply -f 0_pv_pvc_role.yaml
kubectl apply -f 1_net_attach_10_1_128_ipam_whereabouts.yaml
kubectl apply -f br-10-1-128-1-static-for_cfos.yaml
kubectl apply -f 3_cfosdeployment.yaml
kubectl apply -f deployment_tool_net1.yaml
kubectl apply -f cfosdefaultroute.yaml
kubectl apply -f firewallpolicy.yaml
sleep 10
kubectl delete -f 3_cfosdeployment.yaml
sleep 10
kubectl apply -f 3_cfosdeployment.yaml

