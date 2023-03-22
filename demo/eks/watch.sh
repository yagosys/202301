#!/bin/bash

# Set the namespace and deployment name
NAMESPACE="default"
DEPLOYMENT_NAME="multitool01-deployment"

# Set the label selector for the pods you want to watch
LABEL_SELECTOR="app=multitool01"

SRC_ADDR_GROUP=$NAMESPACE$LABEL_SELECTOR

# Initialize an empty list to store the IP addresses
IP_LIST=()
kubectl run pod --image=praqma/network-multitool
sleep 10
# Loop indefinitely to watch for changes in the IP addresses of the pods
old_POD_IPS=$(kubectl get pods -n default -l app=multitool01 -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' ')
while true; do
  # Use kubectl to get the IP addresses of the pods that match the label selector
  #POD_IPS=$(kubectl get pods -n $NAMESPACE -l $LABEL_SELECTOR -o jsonpath='{.items[*].status.podIP}')
          
          POD_IPS=$(kubectl get pods -n default -l app=multitool01 -o json | jq -r  '.items[].metadata.annotations."k8s.v1.cni.cncf.io/network-status" | fromjson | .[] | select(.interface == "net1") | .ips[]' | uniq | tr '\n' ' ')
          echo $POD_IPS
          if [ "$POD_IPS" != "$old_POD_IPS" ]; then
          
             # Convert the space-separated list of IP addresses to an array
                read -ra IP_ARRAY <<< "$POD_IPS"
                MEMBER=""
                MEMBER1=""
              
                # Loop through the array of IP addresses
                for IP in "${IP_ARRAY[@]}"; do
                  # Check if the IP address is already in the list
                #  if [[ ! " ${IP_LIST[*]} " =~ " $IP " ]]; then
                    # If the IP address is not in the list, add it and print a message
                    IP_LIST+=("$IP")
                    echo "New pod IP address detected: $IP, update cfos firewall address"
                    kubectl exec -it po/pod -- curl -H "Content-Type: application/json" -X POST -d '{ "data": {"name": "'$IP'", "subnet": "'$IP' 255.255.255.255"}}' http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address
                    #sleep 1
                    MEMBER='{"name":"'$IP'"},'
                    MEMBER1+=$MEMBER
                #  fi
                
                done
              
                #echo '\n'
                memberlist="[$(echo "$MEMBER1" | sed 's/,$//')]"
              
                #echo $memberlist
                #echo '\n'
                
              #memberlist='[{"name":"10.0.52.19"},{"name":"10.0.53.237"},{"name":"10.0.19.107"},{"name":"10.0.17.202"}]'
              
                EXECLUDEIP="none"
                #
                if kubectl exec -it po/pod -- curl \
                  -H "Content-Type: application/json" \
                  -X PUT \
                  -d '{"data": {"name": "'$SRC_ADDR_GROUP'", "member": '$memberlist', "exclude": "enable", "exclude-member": [ {"name": "'$EXECLUDEIP'"}]}}' \
                  http://fos-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp
                then
                  echo $memberlist added to cfos
                  old_POD_IPS=$POD_IPS
                fi
                
                # Sleep for 10 seconds before checking again
         fi       #
                sleep 10
                echo 'wait 10 seconds and then detect PODS ip changing'
        
done
