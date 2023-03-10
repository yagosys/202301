k8s master node will use userdata to install k8s

- install_crio_1_25_0

download below deb package from https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable  and install it.

```
    sudo dpkg -i conmon_2.1.2~0_amd64.deb
    sudo dpkg -i containers-common_1-22_all.deb
    sudo dpkg -i cri-o_1.25.2~0_amd64.deb
    sudo dpkg -i cri-o-runc_1.0.1~2_amd64.deb
    sudo dpkg -i cri-tools_1.25.0~0_amd64.deb
```

- installcni
download cni version 1.1.1  plugins from https://github.com/containernetworking/plugins/releases/download/ and install it 

- create_crio_config

create /etc/crio/crio.conf with content , this is to tell crio the cni plugins configuration. 

```
[crio.network]
network_dir = "/etc/cni/net.d/"
        plugin_dirs = [
	"/opt/cni/bin/",
	"/usr/lib/cni/",
	]
```


- aptgetupdate_install_tools

install  socat conntrack jq apt-transport-https ca-certificates nfs-server 


- installcrictl

install 1.25.0 version crictl tool from 
```
https://github.com/kubernetes-sigs/cri-tools/releases/download 
```
crictl is client tool for crio daemon, crictl pull can pull the image for create container

- install_kubeadm_kubele_kubectl


download 1.26.0 version kubeadm, kubelet and kubectl. also download 0.4.0 version configuration file for kubeadm and kubectl from 
```
https://dl.k8s.io/release/$RELEASE/bin/linux/$ARCH/{kubeadm,kubelet} 
https://raw.githubusercontent.com/kubernetes/release/$RELEASE_VERSION/cmd/kubepkg/templates/latest/deb.  

ubuntu@ip-10-0-1-100:/etc/systemd/system/kubelet.service.d$ cat 10-kubeadm.conf

[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

```


- install_kubernetes

SERVICE_CIDR , POD_CIDR are from terraform variable. k8s is listening on node private ip.
```
sudo kubeadm init --cri-socket=unix:///var/run/crio/crio.sock --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --service-cidr=$SERVICE_CIDR --pod-network-cidr=$POD_CIDR --node-name $NODENAME  --token-ttl=0 -v=5
```

- install_whereabouts_plugin

```
install whereabouts plugin. it's the latest version and default configuration 

```

- install_flannel_if_worker_node_exist_otherwise_untaint_master_node
install flannel CNI if workernode exist, if only has master node. then flannel will not be installed. 
it also remove default bridge cni configuration if it exist. 
```
 kubectl --kubeconfig /home/ubuntu/.kube/config apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

- install_multus_cni_if_worker_node_exist
if only has master node. multus will use autogenerated config
if workernode exist, multus will use 70-multus.conf 
pull multus image first before deploy it ,otherwise the script will fail 
also delete cni0 interface on the worker node if it exist. bridge CNI might already installed cni0 interface. it that happen, when multus delegate to bridge CNI to create host interface, it may fail. so we have to delete cni0 if it exist. 

```
git clone https://github.com/intel/multus-cni.git
cat /home/ubuntu/multus-cni/deployments/multus-daemonset.yml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
```

- install_docker_secret_and_cfos_license

install docker_secret for pull cfos image
install cfos license 

- create_token_for_worker_to_join
create a shell file with token for worker node to join
```
grep --text discovery-token-ca-cert /var/log/user-data.log -B 1 | head -n 2 | tr -d '\n' | tr -d '\\' > /home/ubuntu/workloadtojoin.sh
```

- rename_70_multus_to_00_multus_conf

rename 70_multus.conf to 00_multus.conf to make multus become the first CNI of k8s.

- function_restart_coredns_deployment_after_install_multus
after install multus. the coredns will obtain IP from multus CNI. before install multus, coredns already got ip from bridge CNI. restart coredns daemonSet is required.


- install_gatekeeperv3

install gatekeeperv3, this will evalute the egress networking policy and submit it to cfos API 

- git_clone_cfos_script

clone the code from repositories

- enable_nfs_server_master
install nfs server on master node. this is required if cfos on multiple node cluster want share same configuration. 

- updatehostdns

the master node use aws dns server by default. need add kube-dns to resolve k8s service name, such as kubernetes.default.svc.cluster.local , fos-deployment.default.svc.cluster.local and kube-dns.kube-system.svc.cluster.local etc 

```
cat << EOF | sudo tee -a /etc/systemd/resolved.conf
[Resolve]
DNS=$CLUSTERDNSIP
FallbackDNS=$AWSDNSIP
Domains=cluster.local
EOF
```
