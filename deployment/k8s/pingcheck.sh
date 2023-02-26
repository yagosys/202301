ip=$(terraform output --raw instance_public_ip)
ssh -i ~/.ssh/id_ed25519cfoslab -l ubuntu $ip /home/ubuntu/202301/pingtest.sh
