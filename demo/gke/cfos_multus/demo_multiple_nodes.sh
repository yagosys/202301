file="$HOME/license/dockerpullsecret.yaml"
[ -e $file ] && echo found dockerpullsecret $file || echo "$file  does not exist, exit" && 
file="$HOME/license/fos_license.yaml"
[ -e $file ] && echo found cfos license file $file || echo "$file  does not exist,exit" &&
startdate=$(date)
./00_gcloud_env.sh && \

./00_create_network.sh && \
cd doc && \
./00_doc.sh
cd ./../

./01_gke.sh && \
cd doc && \
./01_doc.sh
cd ./../

./02_modifygkevmipforwarding.sh && \
cd doc && \
./02_doc.sh
cd ./../

echo sleep 60
sleep 60 

./03_install_multus_auto.sh && \
cd doc && \
./03_doc.sh
cd ./../

./04_create_nad_for_cfos.sh && \
cd doc && \
./04_doc.sh
cd ./../

./05_create_nad_macvlan_for_app.sh && \
cd doc && \
./05_doc.sh
cd ./../

./06_create_app_deployment_multitool.sh && \
cd doc && \
./06_doc.sh
cd ./../

./07_apply_license.sh && \

./08_create_cfos_account.sh 
cd doc 
./08_doc.sh
cd ./../

./09_create_cfos_ds.sh 
cd doc 
./09_doc.sh
cd ./../

./10_config_cfos_firewallpolicy.sh 
cd doc 
./10_doc.sh
cd ./../

./11_cfos_ds_restart.sh 
cd doc 
./11_doc.sh
cd ./../

./19_pingtest.sh 

./12_ipstest.sh 
cd doc 
./12_doc.sh
cd ./../

./13_webftest.sh 
cd doc 
./13_doc.sh
cd ./../

./18_create_policy_manager.sh  
cd doc 
./18_doc.sh
cd ./../

./17_delete_policy_300.sh 
cd doc 
./17_doc.sh
cd ./../

./19_pingtest.sh 

./22_ipstest.sh 
cd doc 
./22_doc.sh
cd ./../

./23_webftest.sh 
cd doc 
./23_doc.sh
cd ./../


./24_ssh_into_worker_node_add_custom_route_to_10_conf_cni_file.sh 
cd doc 
./24_doc.sh
cd ./../

./25_delete_app.sh
cd doc 
./25_doc.sh
cd ./../

./26_create_app_deployment_multtool_with_defaultroute.sh
cd doc 
./26_doc.sh
cd ./../

./27_webftest.sh
cd doc 
./27_doc.sh
cd ./../

./38_delete_policy_101.sh 

./46_install_gatekeeperv3.sh

./47_create_gatekeeper_constraint_template.sh


./48_deploy_constraint_fos_cfos.sh

./49_deploy_network_firewall_policy_egress.sh

./50_restart_app.sh

./52_ipstest.sh 

./53_webftest.sh 



echo "-----------" 
echo deploy start from $startdate to $(date)
echo 'done'
echo "-----------"
echo 'do not forget delete resource created in this demo script use ./14_delcuster.sh && ./15_deleteNetwork.sh'


