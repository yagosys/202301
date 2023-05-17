kubectl rollout restart deployment multitool01-deployment && kubectl rollout status deployment multitool01-deployment
echo "sleep 30 seconds for it will take some time to trigger policymanager to update cfos addressgrp"
sleep 30
