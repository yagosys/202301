-  ## What is CNI

Kubernetes CNI stands for Kubernetes Container Network Interface, which is a specification and a set of plugins for configuring network interfaces in Linux containers. CNI is used by Kubernetes to provide networking functionality for containers, allowing them to communicate with each other and with external networks.CNI plugins are responsible for configuring the network interfaces of containers, including assigning IP addresses and routing traffic. Kubernetes supports a variety of CNI plugins, including Calico, Flannel, Weave Net, and many others.

- ### when CNI installed . it will place it self in /opt/cni directory by default
*cni is just a binary exectuable file, which take the json formatted cni config*

```
ubuntu@ip-10-0-1-100:/opt/cni/bin$ ls -al
total 157460
drwxr-xr-x 2 root root     4096 Feb 26 22:56 .
drwxr-xr-x 3 root root     4096 Feb 26 22:54 ..
-rwxr-xr-x 1 root root  3859475 Jan 16 21:42 bandwidth
-rwxr-xr-x 1 root root  4299004 Jan 16 21:42 bridge
-rwxr-xr-x 1 root root 10167415 Jan 16 21:42 dhcp
-rwxr-xr-x 1 root root  3986082 Jan 16 21:42 dummy
-rwxr-xr-x 1 root root  4385098 Jan 16 21:42 firewall
-rwxr-xr-x 1 root root  2342446 Feb 26 22:56 flannel
-rwxr-xr-x 1 root root  3870731 Jan 16 21:42 host-device
-rwxr-xr-x 1 root root  3287319 Jan 16 21:42 host-local
-rwxr-xr-x 1 root root  3999593 Jan 16 21:42 ipvlan
-rwxr-xr-x 1 root root  3353028 Jan 16 21:42 loopback
-rwxr-xr-x 1 root root  4029261 Jan 16 21:42 macvlan
-rwxr-xr-x 1 root root 42573547 Feb 26 22:56 multus
-rwxr-xr-x 1 root root  3746163 Jan 16 21:42 portmap
-rwxr-xr-x 1 root root  4161070 Jan 16 21:42 ptp
-rwxr-xr-x 1 root root  3550152 Jan 16 21:42 sbr
-rwxr-xr-x 1 root root  2845685 Jan 16 21:42 static
-rwxr-xr-x 1 root root  3437180 Jan 16 21:42 tuning
-rwxr-xr-x 1 root root  3993252 Jan 16 21:42 vlan
-rwxr-xr-x 1 root root  3586502 Jan 16 21:42 vrf
-rwxr-xr-x 1 root root 45721760 Feb 26 22:56 whereabouts

```

- ###  check CNI version 

```
ubuntu@ip-10-0-1-100:/opt/cni/bin$ ./bridge --help
CNI bridge plugin v1.2.0
CNI protocol versions supported: 0.1.0, 0.2.0, 0.3.0, 0.3.1, 0.4.0, 1.0.0
```

- ### how CNI works

CNI is being called with json file and command like CNI_COMMAND=ADD 

```
{
    "cniVersion": "1.0.0",
    "name": "dbnet",
    "type": "bridge",
    "bridge": "cni0",
    "ipam": {
        "type": "host-local",
        "subnet": "10.1.0.0/16",
        "gateway": "10.1.0.1"
    },
    "dns": {
        "nameservers": [ "10.1.0.1" ]
    }
}
```
*above json file tell bridge cni to create a bridge with name dbnet, interface on host is cni0, and delegate the IPAM to another CNI host-local*

*cnitool can be used to add/del interface to a POD as a debug tool*

```
sudo snap install go --classic
go install github.com/containernetworking/cni/cnitool@latest
```

*cni can be single or chained. single cni configuration with extension .conf, and chained with extension .conflist*

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ ls
00-multus.conf  10-flannel.conflist  200-loopback.conf  87-podman-bridge.conflist.dpkg-new  87-podman.conflist  multus.d  whereabouts.d
```
- ###  use cnitool to add a veth interface to a net namespace 

*network name cbr0 is from flannel cni configuration*

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ cat 10-flannel.conflist
{
  "name": "cbr0",
  "cniVersion": "0.3.1",
  "plugins": [
    {
      "type": "flannel",
      "delegate": {
        "hairpinMode": true,
        "isDefaultGateway": true
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    }
  ]
}
```
*let'us use cnitool to add interface to a net namespace*

sudo ip netns add testing
`sudo CNI_PATH="/opt/cni/bin/" /home/ubuntu/go/bin/cnitool add cbr0 /var/run/netns/testing  


*CNI_PATH="/opt/cni/bin/": Sets the environment variable CNI_PATH to /opt/cni/bin/, which is the directory where CNI plugins are installed*
*/home/ubuntu/go/bin/cnitool: Specifies the location of the cnitool executable*
*add cbr0: Add network cbr0 where it use bridge interface name cni0 on the host and eth0 on linux net namespace*
*/var/run/netns/testing: Specifies the network namespace in which the interface is created (testing)*

```
sudo CNI_PATH="/opt/cni/bin/" /home/ubuntu/go/bin/cnitool add cbr0 /var/run/netns/testing  
map[string]interface {}{"cniVersion":"0.3.1", "hairpinMode":true, "ipMasq":false, "ipam":map[string]interface {}{"ranges":[][]map[string]interface {}{[]map[string]interface {}{map[string]interface {}{"subnet":"10.244.0.0/24"}}}, "routes":[]types.Route{types.Route{Dst:net.IPNet{IP:net.IP{0xa, 0xf4, 0x0, 0x0}, Mask:net.IPMask{0xff, 0xff, 0x0, 0x0}}, GW:net.IP(nil)}}, "type":"host-local"}, "isDefaultGateway":true, "isGateway":true, "mtu":(*uint)(0xc0000209a8), "name":"cbr0", "type":"bridge"}
delegateAdd: netconf sent to delegate plugin:
{"cniVersion":"0.3.1","hairpinMode":true,"ipMasq":false,"ipam":{"ranges":[[{"subnet":"10.244.0.0/24"}]],"routes":[{"dst":"10.244.0.0/16"}],"type":"host-local"},"isDefaultGateway":true,"isGateway":true,"mtu":8951,"name":"cbr0","type":"bridge"}{
    "cniVersion": "0.3.1",
    "interfaces": [
        {
            "name": "cni0",
            "mac": "86:1b:68:05:a2:cb"
        },
        {
            "name": "vethcafa0502",
            "mac": "86:d1:e8:af:7f:9e"
        },
        {
            "name": "eth0",
            "mac": "4e:66:92:6e:86:d4",
            "sandbox": "/var/run/netns/testing"
        }
    ],
    "ips": [
        {
            "version": "4",
            "interface": 2,
            "address": "10.244.0.2/24",
            "gateway": "10.244.0.1"
        }
    ],
    "routes": [
        {
            "dst": "10.244.0.0/16"
        },
        {
            "dst": "0.0.0.0/0",
            "gw": "10.244.0.1"
        }
    ],
    "dns": {}
```
*delete interface*
```
sudo CNI_PATH="/opt/cni/bin/" /home/ubuntu/go/bin/cnitool del cbr0 /var/run/netns/testing  
```

*execute into testing linux net namespace*

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo  ip netns exec testing bash
root@ip-10-0-1-100:/etc/cni/net.d# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default
    link/ether 4e:66:92:6e:86:d4 brd ff:ff:ff:ff:ff:ff link-netns 9bcbbf46-4c1f-4bd8-8841-262e7ef10264
    inet 10.244.0.2/24 brd 10.244.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::4c66:92ff:fe6e:86d4/64 scope link
       valid_lft forever preferred_lft forever
root@ip-10-0-1-100:/etc/cni/net.d#
```
*on list host, an interface with name cni0 is also created*

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ ip add show dev cni0
7: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default qlen 1000
    link/ether 86:1b:68:05:a2:cb brd ff:ff:ff:ff:ff:ff
    inet 10.244.0.1/24 brd 10.244.0.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::841b:68ff:fe05:a2cb/64 scope link
       valid_lft forever preferred_lft forever

```

- ### troubleshooting cni config related issue

*most common mistake is cni config has incorrect syntax, for example, below are incorrect cni config*

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ cat 100-flannel.bad.conflist
{
  "name": "badcbr0",
  "cniVersion": "0.3.1",
  "plugins": [
    {
      "type": "flannel",
      "delegate": {
        "hairpinMode": true
        "isDefaultGateway": true
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    }
  ]
}
```

this configuration file will be read by crio. and crio will complain the syntx error. 

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ journalctl -f -u crio
Mar 16 06:44:22 ip-10-0-1-100 crio[1680]: time="2023-03-16 06:44:22.290241151Z" level=info msg="CNI monitoring event WRITE         \"/etc/cni/net.d/.100-flannel.bad.conflist.swp\""
Mar 16 06:44:22 ip-10-0-1-100 crio[1680]: time="2023-03-16 06:44:22.308184183Z" level=info msg="Found CNI network cbr0 (type=flannel) at /etc/cni/net.d/10-flannel.conflist"
Mar 16 06:44:22 ip-10-0-1-100 crio[1680]: time="2023-03-16 06:44:22.308254175Z" level=error msg="Error loading CNI config list file /etc/cni/net.d/100-flannel.bad.conflist: error parsing configuration list: invalid character '\"' after object key:value pair"

```
