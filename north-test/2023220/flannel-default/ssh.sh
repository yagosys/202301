sudo ip add del 10.1.128.1/24 dev cni5

kubectl get node | grep ip- | awk '{print $1}' | while read line; do  address=`echo $line |  awk -F'-' '{print $2"."$3"."$4"."$5}'`; ssh -i ~/.ssh/id_ed25519cfoslab $address sudo ip  add add dev cni5 10.1.128.1/24 ; done
