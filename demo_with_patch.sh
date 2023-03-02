replicas=4
function_curl_from_each_pod() {
        for i in $(kubectl get pod -l app=mynginxtest01 -o json | jq -r '.items | keys | .[]'); do
  pod_name=$(kubectl get pod -l app=mynginxtest01 -o json | jq -r .items[$i].metadata.name)
  echo from $pod_name to curl https://www.eicar.org/download/eicar.com.txt
  kubectl exec -it $pod_name -- curl -k -I https://www.eicar.org/download/eicar.com.txt | grep HTTP/1.1
done
}
kubectl create deployment mynginxtest01 --image=nginx --replicas=$replicas
kubectl rollout status deployment mynginxtest01

function_curl_from_each_pod

echo patch deployment with additional network and add default route
kubectl patch deployment mynginxtest01 -p '{"spec": {"template":{"metadata":{"annotations":{"k8s.v1.cni.cncf.io/networks":"[{\"name\": \"cfosdefaultcni5\", \"default-route\": [\"10.1.128.2\"]}]"}}}}}'

kubectl rollout status deployment mynginxtest01
sleep 30

function_curl_from_each_pod

echo remove patch
kubectl rollout undo deployment mynginxtest01

sleep 30
function_curl_from_each_pod
echo delete deployment
#kubectl delete deployment mynginxtest01
