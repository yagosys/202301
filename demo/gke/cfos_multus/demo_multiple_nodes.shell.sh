startdate=$(date)
./00_a_gcloud_env.sh 
cd doc
./00_a_doc.sh
cd ./../

./00_create_network.sh 
cd doc 
./00_doc.sh
cd ./../

./00_create_cfos_image.sh
cd doc
./00_create_image.doc.sh
cd ./../

./01_gke.sh 
cd doc 
./01_doc.sh
cd ./../

./02_modifygkevmipforwarding.sh.shell.sh 
cd doc  
./02_doc.sh.shell.sh
cd ./../

echo sleep 60
sleep 60 

./03_install_multus_auto.sh && \
cd doc && \
./03_doc.sh
cd ./../

./04_create_nad_for_cfos.sh.shell.sh && \
cd doc && \
./04_doc.sh.shell.sh
cd ./../

./05_create_nad_macvlan_for_app.sh.shell.sh && \
cd doc && \
./05_doc.sh.shell.sh
cd ./../

./06_create_app_deployment_multitool.sh.shell.sh && \
cd doc && \
./06_doc.sh.shell.sh
cd ./../

./07_apply_license.sh && \
cd doc && \
./07_doc.sh
cd ./../

./08_create_cfos_account.sh 
cd doc 
./08_doc.sh
cd ./../

./09_create_cfos_ds.sh.shell.sh 
cd doc 
./09_doc.sh.shell.sh
cd ./../

./10_config_cfos_firewallpolicy.sh.shell.sh 
cd doc 
./10_doc.sh.shell.sh
cd ./../

./11_cfos_ds_restart.sh.shell.sh 
cd doc 
./11_doc.sh.shell.sh
cd ./../

./19_pingtest.sh 

./12_ipstest.sh.shell.sh 
cd doc 
./12_doc.sh.shell.sh
cd ./../

./13_webftest.sh.shell.sh 
cd doc 
./13_doc.sh.shell.sh
cd ./../

./17_delete_policy_300.sh.shell.sh 
cd doc 
./17_doc.sh.shell.sh
cd ./../

./18_create_policy_manager.sh  
cd doc 
./18_doc.sh
cd ./../

./22_ipstest.sh.shell.sh
cd doc 
./22_doc.sh.shell.sh
cd ./../

./23_webftest.sh.shell.sh 
cd doc 
./23_doc.sh.shell.sh
cd ./../


./24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh.shell.sh
cd doc 
./24_doc.sh.shell.sh
cd ./../

./25_delete_app.sh
cd doc 
./25_doc.sh
cd ./../

./26_create_app_deployment_multtool_with_defaultroute.sh.shell.sh
cd doc 
./26_doc.sh.shell.sh
cd ./../

./27_webftest.sh.shell.sh
cd doc 
./27_doc.sh.shell.sh
cd ./../

./38_delete_policy_101.sh.shell.sh 

cd doc 
./38_doc.sh.shell.sh
cd ./../

./46_install_gatekeeperv3.sh

cd doc 
./46_doc.sh
cd ./../

./47_create_gatekeeper_constraint_template.sh

cd doc 
./47_doc.sh
cd ./../


./48_deploy_constraint_fos_cfos.sh.shell.sh
cd doc 
./48_doc.sh.shell.sh
cd ./../

echo sleep 30
sleep 30

./49_deploy_network_firewall_policy_egress.sh
cd doc 
./49_doc.sh
cd ./../

./50_restart_app.sh
cd doc 
./50_doc.sh
cd ./../

./52_ipstest.sh.shell.sh 
cd doc 
./52_doc.sh.shell.sh
cd ./../

./53_webftest.sh.shell.sh
cd doc 
./53_doc.sh.shell.sh
cd ./../



echo "-----------" 
echo deploy start from $startdate to $(date)
echo 'done'
echo "-----------"
echo 'do not forget delete resource created in this demo script use ./00_a_gcloud_env.sh && ./del_cluster.sh && ./del_networks.sh'


