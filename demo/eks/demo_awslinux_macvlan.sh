#!/bin/bash

function do_demo_new {
echo "start"
./00_create_eks_cluster.sh  ;  
./01_create_multus_ds_v393.sh &&  \
./02_create_nad.sh && \
./03_deploy_cfos_license_and_cfos_pull_secret.sh && \
./04_create_cfos_account.sh && \
./05_create_cfos_ds_service.sh && \
./06_create_deployment_app.sh && \
./07_create_deployment_new_test.sh && \
./08_create_policy_manager.sh && \
sleep 5 && \
./09_pingtest.sh && \
./09_2_check_cfos_health.sh && \
./10_webfilter.sh
}

dockersecretfile="$HOME/license/dockerpullsecret.yaml"
cfoslicensefile="$HOME/license/fos_license.yaml"

if [[ -f "$dockersecretfile" ]] && [[ -f "$cfoslicensefile" ]]; then
do_demo_new
else
echo need dockersecret and cfos license to continue
fi
