#!/bin/bash -xe
echo ' - how to run demo ' > README.md
echo ' ``` ' >> README.md
echo 'source ./variable.sh' >> README.md
echo './demo_multiple_nodes.sh' >> README.md
echo ' ``` ' >> README.md

echo 'or do it step by step according below procedure ' >> README.md
echo 'merge document' 

cat  \
./../00_create_network.sh.md \
./../01_gke.sh.md \
./../02_modifygkevmipforwarding.sh.md \
./../03_install_multus_auto.sh.md \
./../04_create_nad_for_cfos.sh.md \
./../05_create_nad_macvlan_for_app.sh.md \
./../06_create_app_deployment_multitool.sh.md \
./../08_create_cfos_account.sh.md \
./../09_create_cfos_ds.sh.md \
./../10_config_cfos_firewallpolicy.sh.md \
./../11_cfos_ds_restart.sh.md \
./../12_ipstest.sh.md \
./../13_webftest.sh.md \
./../17_delete_policy_300.sh.md \
./../18_create_policy_manager.sh.md \
./../22_ipstest.sh.md \
./../23_webftest.sh.md \
./../24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh.md \
./../25_delete_app.sh.md \
./../26_create_app_deployment_multtool_with_defaultroute.sh.md \
./../27_webftest.sh.md  > README.md
