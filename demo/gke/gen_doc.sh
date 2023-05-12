#!/bin/bash -xe
echo ' - how to run demo ' > README.md
echo '` ./demo.sh`' to run demo  >> README.md
echo 'or do it step by step according below procedure ' >> README.md
echo "generate document"
./00_doc.sh
./01_doc.sh
./02_doc.sh
./03_doc.sh
./04_doc.sh
./05_doc.sh
./07_doc.sh
./08_doc.sh 
./09_doc.sh
./10_doc.sh
./11_doc.sh
./12_doc.sh
./13_doc.sh

echo 'merge document' 

cat  \
00_create_network.sh.md  \
01_gke.sh.md  \
02_modifygkevmipforwarding.sh.md  \
03_install_multus.sh.md  \
04_create_nad.sh.md  \
05_create_app_deployment.sh.md  \
07_create_cfos_account.sh.md  \
08_create_cfos_ds.sh.md  \
09_config_cfos_firewallpolicy.sh.md  \
10_config_cfos_staticroute.sh.md  \
11_cfos_ds_restart.sh.md  13_webftest.sh.md  \
12_ipstest.sh.md >> README.md
