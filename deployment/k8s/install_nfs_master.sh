sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y nfs-server
sudo -u ubuntu  mkdir /home/ubuntu/data
cat << EOF | sudo   tee  /etc/exports
/home/ubuntu/data 10.0.1.100(rw,no_subtree_check,no_root_squash)
EOF
sudo systemctl enable --now nfs-server
sudo exportfs -ar
