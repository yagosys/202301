ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200 sudo ip  link delete cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201 sudo ip  link delete cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.200 sudo ip  add add 10.1.128.1/24 dev cni5
ssh -i ~/.ssh/id_ed25519cfoslab 10.0.2.201 sudo ip  add add 10.1.128.1/24 dev cni5
