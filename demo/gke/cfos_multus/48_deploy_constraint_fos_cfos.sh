#!/bin/bash
filename="48_constraint_for_cfos.yml"
[[ -z $gatekeeper_policy_id ]] && gatekeeper_policy_id="200"
[[ -z $cfos_label ]] && cfos_label="fos"

cat << EOF >$filename
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sEgressNetworkPolicyToCfosUtmPolicy
metadata:
  name: cfosnetworkpolicy
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: ["networking.k8s.io"]
        kinds: ["NetworkPolicy"]
  parameters:
    firewalladdressapiurl : "http://$cfos_label-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/address"
    firewallpolicyapiurl : "http://$cfos_label-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/policy"
    firewalladdressgrpapiurl: "http://$cfos_label-deployment.default.svc.cluster.local/api/v2/cmdb/firewall/addrgrp"
    policyid : "$gatekeeper_policy_id"
    label: "cfosegressfirewallpolicy"
    outgoingport: "eth0"
    utmstatus: "enable"
    ipsprofile: "default"
    avprofile: "default"
    sslsshprofile: "deep-inspection"
    action: "permit"
    srcintf: "any"
    extraservice: "PING"
EOF

kubectl apply -f $filename && kubectl get k8segressnetworkpolicytocfosutmpolicy -o yaml
