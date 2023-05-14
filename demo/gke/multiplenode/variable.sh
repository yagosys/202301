#/bin/bash
export networkName="gkenetwork1" 
export subnetName="gkenode" 
export ipcidrRange="10.0.0.0/24" 
export firewallruleName="$networkName-allow-custom" 
export firewallallowProtocol="all"
export defaultClustername="my-first-cluster-1"
export machineType="g1-small" #"e2-standard-2"
export num_nodes="2"
