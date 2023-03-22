#!/bin/bash

function updatecfosfirewalladdress {
  kubectl exec -it po/clientpod -- curl -H "Content-Type: application/json" -X POST -d '{ "data": {"name": "'$IP'", "subnet": "'$IP' 255.255.255.255"}}' http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address
}

function updatecfosfirewalladdressgroup {
                local memberlist="$1"
                if kubectl exec -it po/clientpod -- curl \
                  -H "Content-Type: application/json" \
                  -X PUT \
                  -d '{"data": {"name": "'$SRC_ADDR_GROUP'", "member": '$memberlist', "exclude": "enable", "exclude-member": [ {"name": "'$EXECLUDEIP'"}]}}' \
                  http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp
                then
                  echo $memberlist added to cfos
                  old_POD_IPS=$POD_IPS
                fi               
}

function createcfosfirewallpolicy {
              if kubectl exec -it po/clientpod --  curl \
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
                http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy
              then 
                echo $firewall policy created on cfos
              fi
  
}


function getPodNet1Ips {
  local namesapce="$1"
  local label="$2"
  kubectl get pods -n "$namespace" -l "$label" -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' '
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

                    updatecfosfirewalladdress

                    MEMBER='{"name":"'$IP'"},'
                    MEMBER1+=$MEMBER

                done
              
                memberlist="[$(echo "$MEMBER1" | sed 's/,$//')]"
                echo $memberlist
  
                EXECLUDEIP="none"
                updatecfosfirewalladdressgroup $memberlist
                
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
                
         fi  
                sleep $INTERVAL
                echo 'loop for  detect PODS ip changing'
        
done
}

# Set the namespace and deployment name
NAMESPACE="default"
DEPLOYMENT_NAME="multitool01-deployment"

# Set the label selector for the pods you want to watch
LABEL_SELECTOR="app=multitool01"

SRC_ADDR_GROUP=$(echo $NAMESPACE$LABEL_SELECTOR | sed 's/[^A-Za-z]//g')
#SRC_ADDR_GROUP="cfossrc"
INTERVAL=10

# Initialize an empty list to store the IP addresses

#kubectl run pod --image=praqma/network-multitool
createClientPod
POD_IPS=$(getPodNet1Ips $NAMESPACE  $LABEL_SELECTOR)
#echo calling updateCfos with $POD_IPS
updateCfos
createcfosfirewallpolicy


watchPodandUpdateCfosFirwallAddressGrpforSelectedNamespaceandLabel

