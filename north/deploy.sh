   kubectl apply -f 0_pv_pvc_role.yaml
   kubectl apply -f 1_net_attach_10_1_128.yaml
   kubectl apply -f 2_net_attach_10_2_128.yaml
   kubectl apply -f br-10-1-128-1-static-for_cfos.yaml
   kubectl apply -f br-10-2-128-1-static-for-cfos.yaml
   kubectl apply -f 3_cfosdeployment.yaml
   kubectl apply -f deployment_tool_net1_vrf.yaml
