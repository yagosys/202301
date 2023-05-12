#/bin/bash
export networkName="gkenetwork1" 
export subnetName="gkenode" 
export ipcidrRange="10.0.0.0/24" 
export firewallruleName="$networkName-allow-custom" 
export firewallallowProtocol="tcp:22"
export defaultClustername="my-first-cluster-1"
