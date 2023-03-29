#!/bin/bash
function restartcfosifnodenumberchanaged {
previous_node_count=$(kubectl get nodes -o json | jq '.items | length')
echo $previous_node_count

while true; do
  node_count=$(kubectl get nodes -o json | jq '.items | length')

  if [ "$previous_node_count" -ne "$node_count" ]; then
    echo "Number of nodes changed: $node_count"
    echo "restart fos-deployment"
    kubectl rollout status ds/kube-multus-ds -n kube-system
    sleep 30
    kubectl rollout restart ds/fos-deployment
    previous_node_count="$node_count"
  fi
  sleep 180 
  echo "watch node number change"
done
}

function getCfosPodIp {
cfospodips=($(kubectl get pods -l app=fos -o json | jq -r '.items[].status.podIP'))
echo cfospodips
}


function getPolicyId {
policyid=$(kubectl get K8sEgressNetworkPolicyToCfosUtmPolicy cfosnetworkpolicy -o jsonpath='{.spec.parameters.policyid}')
echo $policyid
}

function getPodApplabel {
	label_value=$(kubectl get pods -o json -A | jq -r '[.items[] | select(.metadata.annotations != null and .metadata.annotations["k8s.v1.cni.cncf.io/networks"] != null and (.metadata.annotations["k8s.v1.cni.cncf.io/networks"] | (contains("cfosdefaultcni5") and contains("default-route")))) | .metadata.labels.app] | unique[]')
	LABEL_SELECTOR=$(echo app=$label_value)
	echo $LABEL_SELECTOR
}

function getPodNamespace {
namespace=$(kubectl get pods -o json -A | jq -r '[.items[] | select(.metadata.annotations != null and .metadata.annotations["k8s.v1.cni.cncf.io/networks"] != null and (.metadata.annotations["k8s.v1.cni.cncf.io/networks"] | (contains("cfosdefaultcni5") and contains("default-route")))) | .metadata.namespace] | unique[]')
        echo $namespace
}


function curltocfosupdatefirewalladdress {
  for ip in "${cfospodips[@]}"; do
  cfosurl=$ip
  #cfosurl=http://fos-deployment.default.svc.cluster.local
  curl -H "Content-Type: application/json" -X POST -d '{ "data": {"name": "'$IP'", "subnet": "'$IP' 255.255.255.255"}}' http://$cfosurl/api/v2/cmdb/firewall/address
  done 
}

function updatecfosfirewalladdress {
  getCfosPodIp
  echo updatecfosfirewalladdress IP=$IP
  curltocfosupdatefirewalladdress

#  curl -H "Content-Type: application/json" -X POST -d '{ "data": {"name": "'$IP'", "subnet": "'$IP' 255.255.255.255"}}' http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address
}

function curltocfosupdatefirewalladdrgrp {
      for ip in "${cfospodips[@]}"; do
      cfosurl=$ip
      curl \
                  -H "Content-Type: application/json" \
                  -X PUT \
                  -d '{"data": {"name": "'$SRC_ADDR_GROUP'", "member": '$memberlist', "exclude": "enable", "exclude-member": [ {"name": "'$EXECLUDEIP'"}]}}' \
                  http://$cfosurl/api/v2/cmdb/firewall/addrgrp
                  #http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp
      done
}

function updatecfosfirewalladdressgroup {
                local memberlist="$1"
                echo memberlist=$memberlist
                getCfosPodIp
                if curltocfosupdatefirewalladdrgrp
                then
                  echo $memberlist added to cfos
                  old_POD_IPS=$POD_IPS
                fi               
}

function createcfosfirewallpolicy {
      for ip in "${cfospodips[@]}"; do
      cfosurl=$ip
              if  curl \
               -H "Content-Type: application/json" \
               -X POST \
               -d '{ "data": 
                     {"policyid":"20", 
                       "name": "corp-traffic", 
                       "srcintf": [{"name": "any"}], 
                       "dstintf": [{"name": "eth0"}], 
                       "srcaddr": [{"name": "'$SRC_ADDR_GROUP'"}],
                       "service": [{"name": "ALL"}],
                       "nat":"enable",
                       "utm-status":"enable",
                       "action": "accept",
                       "logtraffic": "all",
                       "ssl-ssh-profile": "deep-inspection",
                       "ips-sensor": "default",
                       "webfilter-profile": "default",
                       "av-profile": "default",
                       "dstaddr": [{"name": "all"}]}}' \
                http://$cfosurl/api/v2/cmdb/firewall/policy
              then 
                echo $firewall policy created on cfos
              fi
      done
  
}


function getPodNet1Ips {
  #local namesapce="$1"
  #local label="$2"
  kubectl get pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' '
}


function createClientPod {
  while true; do
  if kubectl get pod clientpod 
  then 
  break
  else 
      kubectl run clientpod --image=praqma/network-multitool
  fi
  done
}

function updateCfos {
                #local POD_IPS="$1"
                echo updateCfos got $POD_IPS 
               # Convert the space-separated list of IP addresses to an array
                read -ra IP_ARRAY <<< "$POD_IPS"
                MEMBER=""
                MEMBER1=""
                
                for IP in "${IP_ARRAY[@]}"; do

                    IP_LIST+=("$IP")
                    echo "New pod IP address detected: $IP, update cfos firewall address"
                    echo IP=$IP

                    updatecfosfirewalladdress

                    MEMBER='{"name":"'$IP'"},'
                    MEMBER1+=$MEMBER

                done
              
               if [ -z "$IP" ]; then 
               echo $IP is empty
               else 
               memberlist="[$(echo "$MEMBER1" | sed 's/,$//')]"
                EXECLUDEIP="none"
                echo call updatecfosfirewalladdressgroup $memberlist
                updatecfosfirewalladdressgroup $memberlist
               fi
                
}

function watchPodandUpdateCfosFirwallAddressGrpforSelectedNamespaceandLabel {
IP_LIST=()
old_POD_IPS=$(getPodNet1Ips $NAMESPACE $LABEL_SELECTOR)
#echo $old_POD_IPS
while true; do

          POD_IPS=$(getPodNet1Ips $NAMESPACE  $LABEL_SELECTOR)
          #echo $POD_IPS
          if [ "$POD_IPS" != "$old_POD_IPS" ]; then
          
              updateCfos #$POD_IPS
	      createcfosfirewallpolicyifnogatekeeperpolicyexist
                
         fi  
                sleep $INTERVAL
                echo 'loop for  detect PODS ip changing'
        
done
}

function createcfosfirewallpolicyifnogatekeeperpolicyexist {
policyid=$(getPolicyId)
echo $policyid
if [[ -n "$policyid" ]]; then
echo "policy already created by gatekeeper"
else
createcfosfirewallpolicy
fi
}

# Set the namespace and deployment name
#NAMESPACE="default"
#NAMESPACE=$NAMESPACE
NAMESPACE=$(getPodNamespace)
DEPLOYMENT_NAME="multitool01-deployment"
echo NAMESPACE=$NAMESPACE


# Set the label selector for the pods you want to watch
#LABEL_SELECTOR="app=multitool01"
#LABEL_SELECTOR=$LABEL_SELECTOR
LABEL_SELECTOR=$(getPodApplabel)
echo LABEL=$LABEL_SELECTOR

SRC_ADDR_GROUP=$(echo $NAMESPACE$LABEL_SELECTOR | sed 's/[^A-Za-z]//g')
#SRC_ADDR_GROUP="cfossrc"
INTERVAL=10

# Initialize an empty list to store the IP addresses

POD_IPS=$(getPodNet1Ips $NAMESPACE  $LABEL_SELECTOR)

if [[ -z $POD_IPS ]]; then 
echo "no ip exist "
else
updateCfos
createcfosfirewallpolicyifnogatekeeperpolicyexist

fi

watchPodandUpdateCfosFirwallAddressGrpforSelectedNamespaceandLabel &
restartcfosifnodenumberchanaged &
wait
