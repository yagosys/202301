   kubectl delete -f firewallpolicy.yaml
   kubectl delete -f 1_net_attach_10_1_128_ipam_whereabouts.yaml
   kubectl delete -f br-10-1-128-1-static-for_cfos.yaml
   kubectl delete -f 3_cfosdeployment.yaml
   kubectl delete -f deployment_tool_net1_vrf.yaml
   kubectl delete -f 0_pv_pvc_role.yaml
