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

dnsserver=$(grep nameserver  /run/systemd/resolve/resolv.conf | awk  '{print $2}')
sudo sed -i 's/"dst": "0.0.0.0\/0"/"dst": "10.96.0.0\/12", "gw": "10.85.0.1"},\n            { "dst": "'"$dnsserver"'\/32", "gw": "10.85.0.1"/g' /etc/cni/net.d/100-crio-bridge.conf
kubectl rollout restart ds/kube-multus-ds -n kube-system
waitforMultusReady
sudo tail -f 00-multus.conf --retry | sed '/10.96/q'
