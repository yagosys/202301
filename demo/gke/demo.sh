file="$HOME/license/dockerinterbeing.yaml"
[ -e $file ] && echo found dockerpullsecret $file || echo "$file  does not exist, exit" && 
file="$HOME/license/fos_license.yaml"
[ -e $file ] && echo found cfos license file $file || echo "$file  does not exist,exit" &&
startdate=$(date)
./00_gcloud_env.sh && \
./00_create_network.sh && \
./01_gke.sh && \
./02_modifygkevmipforwarding.sh && \
./03_install_multus.sh && \
./04_create_nad_macvlan.sh && \
./05_create_app_deployment.sh && \
./06_apply_license.sh && \
./07_create_cfos_account.sh && \
./08_create_cfos_ds.sh && \
./09_config_cfos_firewallpolicy.sh && \
./10_config_cfos_staticroute.sh && \
./11_cfos_ds_restart.sh && \
./12_ipstest.sh && \
./13_webftest.sh && \
echo "-----------" 
echo deploy start from $startdate to $(date)
echo 'done'
echo "-----------"
echo 'do not forget delete resource created in this demo script use ./14_delcuster.sh && ./15_deleteNetwork.sh'

