   kubectl apply -f 0_pv_pvc_role.yaml
   kubectl apply -f 1_net_attach_10_1_128_ipam_whereabouts.yaml
   kubectl apply -f br-10-1-128-1-static-for_cfos.yaml
   kubectl apply -f 3_cfosdeployment.yaml
   kubectl apply -f deployment_tool_net1.yaml
   kubectl apply -f firewallpolicy.yaml
