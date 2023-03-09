- crio container runtime
the installed container runtime is crio. crio is the high level container runtime which offer cri interface.
the crio by default use unix socket to communicate with other components, the unix socket address of crio is unix:///var/run/crio/crio.sock

when kubeadm doing init, use --cri-socket to specifc the crio socket. in case you have multiple container runtime running, you need to specify one.


```
sudo kubeadm init --cri-socket=unix:///var/run/crio/crio.sock
```

CRI-O is an open-source container runtime designed to work specifically with Kubernetes, CRI-O communicates with other Kubernetes components using the Container Runtime Interface (CRI)
CRIO use CRI interface talk to both kubernetes API server and kubelet.  kubernetes API send POD request to CRI-O, while kubelet actually create the POD.  CRI-O is also managing the CNI plugin.
runc is low level container runtime, CRIO-O use runc as it's runtime. 

the configuration of crio by default is under /etc/crio/crio.conf.d . the crio runctime configuration is /etc/crio/crio.conf.d/01-crio-runc.conf 

here is a few command that can be used to check the crio status


- check container default linux capabilities.

```
ubuntu@ip-10-0-1-100:/etc/crio/crio.conf.d$ sudo crio-status config | grep default_capabilities
    default_capabilities = ["CHOWN", "DAC_OVERRIDE", "FSETID", "FOWNER", "SETGID", "SETUID", "SETPCAP", "NET_BIND_SERVICE", "KILL"]`
```
above you will see that crio by default does not grant NET_RAW to POD. so by default container will not able to use ping command


- check crio cni plugin configuration

```
ubuntu@ip-10-0-1-100:/etc/crio/crio.conf.d$ sudo crio-status config | grep crio.network -A 3
  [crio.network]
    cni_default_network = ""
    network_dir = "/etc/cni/net.d/"
    plugin_dirs = ["/opt/cni/bin/", "/usr/lib/cni/"]
```

cni_default_network is the the default CNI network name to be selected. If not set or "", then
 CRI-O will pick-up the first one found in network_dir.

for example, the /etc/cni/net.d/ has 
00-multus.conf  10-flannel.conflist  200-loopback.conf  multus.d  whereabouts.d
. the crio will pickup 00-multus.conf for crio.network configuraiton.

you can use journalctl -f -u crio to check the related log messages 

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo systemctl restart crio
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ journalctl -f -u crio
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.158762582Z" level=info msg="Found CNI network cbr0 (type=flannel) at /etc/cni/net.d/10-flannel.conflist"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.161112967Z" level=info msg="Found CNI network 200-loopback.conf (type=loopback) at /etc/cni/net.d/200-loopback.conf"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.161136770Z" level=info msg="Updated default CNI network name to multus-cni-network"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.412726306Z" level=info msg="Got pod network &{Name:coredns-599c97c45f-4dtxw Namespace:kube-system ID:954f73c86e3e7d6c35cbcfbe44d4ca4cbf3424cbbb80b6f3e82a6288849f5e7e UID:4ae698aa-c194-4cef-915f-d514ba6f21bd NetNS:/var/run/netns/ce686bd8-adff-4363-acb7-08e179251beb Networks:[] RuntimeConfig:map[multus-cni-network:{IP: MAC: PortMappings:[] Bandwidth:<nil> IpRanges:[]}] Aliases:map[]}"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.413436668Z" level=info msg="Checking pod kube-system_coredns-599c97c45f-4dtxw for CNI network multus-cni-network (type=multus)"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.414386133Z" level=info msg="Got pod network &{Name:coredns-599c97c45f-lkdrr Namespace:kube-system ID:c746fdceeb31e2abf24851195f53d8613eb2d4f2a66d4017f898199021235983 UID:af7aac79-bcc3-4d43-9fce-848c44652a72 NetNS:/var/run/netns/0f22796c-414a-466c-8663-af534bb63487 Networks:[] RuntimeConfig:map[multus-cni-network:{IP: MAC: PortMappings:[] Bandwidth:<nil> IpRanges:[]}] Aliases:map[]}"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.414595799Z" level=info msg="Checking pod kube-system_coredns-599c97c45f-lkdrr for CNI network multus-cni-network (type=multus)"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.415747236Z" level=error msg="Writing clean shutdown supported file: open /var/lib/crio/clean.shutdown.supported: no such file or directory"
Feb 27 12:49:27 ip-10-0-1-100 crio[248987]: time="2023-02-27 12:49:27.415931054Z" level=error msg="Failed to sync parent directory of clean shutdown file: open /var/lib/crio: no such file or directory"
Feb 27 12:49:27 ip-10-0-1-100 systemd[1]: Started Container Runtime Interface for OCI (CRI-O).

```

- use crictl to manage container image

crictl is client tool that talk to crio, you can use it to pull image and create container etc.,   
```
ubuntu@ip-10-0-1-100:/etc/crio/crio.conf.d$ sudo crictl image
IMAGE                                      TAG                 IMAGE ID            SIZE
docker.io/flannel/flannel-cni-plugin       v1.1.2              7a2dcab94698c       8.25MB
docker.io/flannel/flannel                  v0.21.2             7b7f3acab868d       65.1MB
docker.io/interbeing/multus-cni            stable              c0e8690ae66a1       218MB
ghcr.io/k8snetworkplumbingwg/whereabouts   latest-amd64        04947e822536d       102MB
registry.k8s.io/coredns/coredns            v1.9.3              5185b96f0becf       48.9MB
registry.k8s.io/etcd                       3.5.6-0             fce326961ae2d       301MB
registry.k8s.io/kube-apiserver             v1.26.1             deb04688c4a35       135MB
registry.k8s.io/kube-controller-manager    v1.26.1             e9c08e11b07f6       125MB
registry.k8s.io/kube-proxy                 v1.26.1             46a6bb3c77ce0       67.2MB
registry.k8s.io/kube-scheduler             v1.26.1             655493523f607       57.7MB
registry.k8s.io/pause                      3.6                 6270bb605e12e       690kB
registry.k8s.io/pause                      3.9                 e6f1816883972       750kB
```
to pull image from registry. use command

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo crictl pull hello-world -D
Image is up to date for docker.io/library/hello-world@sha256:6e8b6f026e0b9c419ea0fd02d3905dd0952ad1feea67543f525c73a0a790fefb
```

use crio-status to display image storge root , which by default , crio use /var/lib/containers/storage. 
```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo crio-status info
cgroup driver: systemd
storage driver: overlay
storage root: /var/lib/containers/storage
default GID mappings (format <container>:<host>:<size>):
  0:0:4294967295
default UID mappings (format <container>:<host>:<size>):
  0:0:4294967295
```

if you need more powerful tool to manage image, you can use podman. 
in additional to pull image, podman and also build image like docker build.

below is a example that use podman to pull image and save to same storage with cri-o

```
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ storageRoot=$(sudo crio-status info | grep 'storage root' | cut -d ':' -f 2)
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ echo $storageRoot
/var/lib/containers/storage
ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo podman --root $storageRoot pull ubuntu:latest
Trying to pull docker.io/library/ubuntu:latest...
Getting image source signatures
Copying blob 677076032cca [--------------------------------------] 0.0b / 0.0b
Copying config 58db3edaf2 done
Writing manifest to image destination
Storing signatures
58db3edaf2be6e80f628796355b1bdeaf8bea1692b402f48b7e7b8d1ff100b02

ubuntu@ip-10-0-1-100:/etc/cni/net.d$ sudo crictl image | grep ubuntu
docker.io/library/ubuntu                   latest              58db3edaf2be6       80.3MB

```


- list a containers detail information with crictl 

get a running container id use crictl command, assume the container has name "fos"
```
ubuntu@ip-10-0-2-200:~$ sudo crictl ps  --name fos
CONTAINER           IMAGE                                                              CREATED             STATE               NAME                ATTEMPT             POD ID              POD
d66f513db6fa5       68ddf4677772a952f7222a5c153e135f7ffe77682bc185fe7753a898adccc504   17 minutes ago      Running             fos                 1                   9dcdc89057f93       fos-deployment-pmrkp
```

then we can use this container id to show the detail information about this container
```
ubuntu@ip-10-0-2-200:~$ sudo crictl inspect d66f513db6fa5 | jq .status.mounts
[
  {
    "containerPath": "/data",
    "hostPath": "/home/ubuntu/data/pv0001",
    "propagation": "PROPAGATION_PRIVATE",
    "readonly": false,
    "selinuxRelabel": false
  },
  {
    "containerPath": "/etc/hosts",
    "hostPath": "/var/lib/kubelet/pods/147b7e3c-419f-4842-9620-52533d366f0b/etc-hosts",
    "propagation": "PROPAGATION_PRIVATE",
    "readonly": false,
    "selinuxRelabel": false
  },
  {
    "containerPath": "/dev/termination-log",
    "hostPath": "/var/lib/kubelet/pods/147b7e3c-419f-4842-9620-52533d366f0b/containers/fos/00ddbe1f",
    "propagation": "PROPAGATION_PRIVATE",
    "readonly": false,
    "selinuxRelabel": false
  },
  {
    "containerPath": "/var/run/secrets/kubernetes.io/serviceaccount",
    "hostPath": "/var/lib/kubelet/pods/147b7e3c-419f-4842-9620-52533d366f0b/volumes/kubernetes.io~projected/kube-api-access-h2d9l",
    "propagation": "PROPAGATION_PRIVATE",
    "readonly": true,
    "selinuxRelabel": false
  }
]
ubuntu@ip-10-0-2-200:~$ sudo crictl inspect d66f513db6fa5 | jq .info.runtimeSpec.process.env
[
  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  "TERM=xterm",
  "HOSTNAME=fos-deployment-pmrkp",
  "FOS_DEPLOYMENT_SERVICE_HOST=10.97.227.69",
  "FOS_DEPLOYMENT_PORT_80_TCP_PORT=80",
  "FOS_DEPLOYMENT_PORT_80_TCP_ADDR=10.97.227.69",
  "KUBERNETES_SERVICE_PORT=443",
  "KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1",
  "FOS_DEPLOYMENT_SERVICE_PORT=80",
  "FOS_DEPLOYMENT_PORT=tcp://10.97.227.69:80",
  "KUBERNETES_SERVICE_PORT_HTTPS=443",
  "KUBERNETES_PORT=tcp://10.96.0.1:443",
  "KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443",
  "FOS_DEPLOYMENT_PORT_80_TCP=tcp://10.97.227.69:80",
  "FOS_DEPLOYMENT_PORT_80_TCP_PROTO=tcp",
  "KUBERNETES_SERVICE_HOST=10.96.0.1",
  "KUBERNETES_PORT_443_TCP_PROTO=tcp",
  "KUBERNETES_PORT_443_TCP_PORT=443",
  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
]

ubuntu@ip-10-0-2-200:~$ sudo crictl inspect d66f513db6fa5 | jq .info.runtimeSpec.linux.namespaces --tab
[
        {
                "type": "pid"
        },
        {
                "type": "network",
                "path": "/var/run/netns/559255e1-f15b-425f-9cbf-d57c17b54848"
        },
        {
                "type": "ipc",
                "path": "/var/run/ipcns/559255e1-f15b-425f-9cbf-d57c17b54848"
        },
        {
                "type": "uts",
                "path": "/var/run/utsns/559255e1-f15b-425f-9cbf-d57c17b54848"
        },
        {
                "type": "mount"
        },
        {
                "type": "cgroup"
        }
]

```
- enter a container's namespace

 for example, below we enter cfos all linux namespace 
```
ubuntu@ip-10-0-2-200:~$ sudo nsenter -a -t `sudo crictl inspect $containerid | jq .info.pid` /bin/sh
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default
    link/ether 3e:15:2b:e4:4e:59 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.1.12/24 brd 10.244.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::3c15:2bff:fee4:4e59/64 scope link
       valid_lft forever preferred_lft forever
3: net1@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ca:fe:c0:ff:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.128.2/24 brd 10.1.128.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::c8fe:c0ff:feff:2/64 scope link
       valid_lft forever preferred_lft forever
# ps
  PID USER       VSZ STAT COMMAND
    1 root      4252 S    {dockerinit} /bin/sh /bin/dockerinit
   51 root      4252 S    /bin/runsvdir /run/fcn_service
   58 root      4120 S    runsv k8swatcher
   59 root      4120 S    runsv cmdbwatcher
   60 root      4252 S    svlogd -tt /var/log/k8swatcher/
   61 root      4120 S    runsv urlfilter
   62 root      4252 S    svlogd -tt /var/log/cmdbwatcher/
   63 root      4120 S    runsv iked
   65 root      4252 S    svlogd -tt /var/log/urlfilter/
   69 root      4120 S    runsv restapi
   70 root      4252 S    svlogd -tt /var/log/iked/
   76 root      4120 S    runsv httpd
   77 root      4120 S    runsv mosquitto
   79 root      4252 S    svlogd -tt /var/log/httpd/
   80 root      4252 S    svlogd -tt /var/log/restapi/
   81 root      4120 S    runsv syslogd
   82 root      4252 S    svlogd -tt /var/log/mosquitto/
   83 root      4120 S    runsv ipsmonitor
   84 root      4252 S    svlogd -tt /var/log/syslogd/
   85 root      4120 S    runsv miglogd
   86 root      4252 S    svlogd -tt /var/log/ipsmonitor/
  106 root      4120 S    runsv certd
  110 root      4252 S    svlogd -tt /var/log/miglogd/
  114 root      4252 S    svlogd -tt /var/log/certd/
  218 root      4252 S    /bin/crond -d 7 -L /var/log/crond.log
  254 root     13896 S    /bin/ipsmonitor
  256 root     1201m S    /bin/certd
  258 mosquitt  3740 S    /bin/mosquitto -c /etc/mosquitto.conf
  282 root      787m S    {ipshelper} /bin/ipsengine c 0 3 -1
  288 root     1126m S    /bin/urlfilter
  289 root      544m S    {node} svcrun restapi289 -r -i 0.0.0.0 -p 80
  290 root     14268 S    /bin/syslogd
  291 root     1052m S    /bin/httpd
  292 root     1053m S    /bin/iked
  294 root     1195m S    /bin/cmdbwatcher
  295 root     1071m S    /bin/k8swatcher
  296 root     15476 S    /bin/miglogd
  352 root      4252 S    /bin/tail -f /var/log/k8swatcher/current
  353 root      894m S    /bin/ipsengine m 1 3 -1
  354 root      830m S    /bin/ipsengine 0 2 3 -1
  372 root      4252 S    /bin/sh
  374 root      4252 R    ps
#

- copy file from host to container

for example, below will copy tcpdump binary from your host to the targetd container

```
sudo cp ./tcpdump `sudo crictl inspect d66f513db6fa5 | jq -r .info.runtimeSpec.root.path`/tmp
```
