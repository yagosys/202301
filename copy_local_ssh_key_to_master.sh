ip=$(terraform output --raw instance_public_ip)
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519cfoslab /home/i/.ssh/id_ed25519cfoslab ubuntu@$ip:.ssh/id_ed25519cfoslab
scp -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519cfoslab /home/i/.ssh/id_ed25519cfoslab.pub ubuntu@$ip:.ssh/id_ed25519cfoslab.pub
