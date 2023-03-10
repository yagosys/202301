kubectl rollout restart ds/kube-multus-ds -n kube-system
kubectl rollout status ds/kube-multus-ds -n kube-system
kubectl rollout restart deployment calico-typha -n calico-system
kubectl rollout restart deployment calico-kube-controllers -n calico-system
kubectl rollout restart ds/csi-node-driver -n calico-system
