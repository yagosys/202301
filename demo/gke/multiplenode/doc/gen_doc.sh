#!/bin/bash -xe
echo ' - how to run demo ' > README.md
echo ' ``` ' >> README.md
echo 'source ./variable.sh' >> README.md
echo './demo_multiple_nodes.sh' >> README.md
echo ' ``` ' >> README.md

echo 'or do it step by step according below procedure ' >> README.md
echo "generate document"
./00_doc.sh
./01_doc.sh
./02_doc.sh
./03_doc.sh
./04_doc.sh
./05_doc.sh
./06_doc.sh
./08_doc.sh 
./09_doc.sh
./10_doc.sh
./11_doc.sh
./12_doc.sh
./13_doc.sh
./17_doc.sh
./18_doc.sh
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
./../18_create_policy_manager.sh.md >> README.md
