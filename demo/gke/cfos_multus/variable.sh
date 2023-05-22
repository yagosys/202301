#/bin/bash
export networkName="gkenetwork1" 
export subnetName="gkenode" 
export ipcidrRange="10.0.0.0/24" 
export firewallruleName="$networkName-allow-custom" 
export firewallallowProtocol="all"
export defaultClustername="my-first-cluster-1"
export machineType="e2-standard-2"
export num_nodes="2"
export master_interface_on_worker_node="ens4"
export net_attach_def_name_for_cfos="cfosdefaultcni5"
export cfosIp="10.1.200.252/32"
export ips_target_url="www.hackthebox.eu"
export webf_target_url="https://www.eicar.org/download/eicar.com.txt"
export my_dst_url="www.vulnhub.com"

index=1
for url in $ips_target_url $webf_target_url $my_dst_url; do
  domain="${url#*://}" && domain="${domain%%/*}" && echo $domain
  iplist=$(dig +short $domain | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

  for ip in $iplist; do
    dst="{ \"dst\": \"$ip/32\", \"gw\": \"${cfosIp%%/*}\"},"
    echo $dst
    echo $custom_dst$index
    export custom_dst$index="$dst"
    ((index++))
  done
done

export ping_dst="1.1.1.1"
export cfosIpshort=$( echo $cfosIp | awk -F '/' '{print $1}')
#export custom_dst1='{ "dst": "1.1.1.1/32", "gw": "10.1.200.252" },'
#export custom_dst1="{ \"dst\": \"$ping_dst/32\", \"gw\": \"$cfosIpshort\" },"
#export custom_dst2='{ "dst": "104.18.0.0/16", "gw": "10.1.200.252"},'
export custom_lastdst='{ "dst": "1.1.1.1/32", "gw": "10.1.200.252"}'
export app_nad_annotation="cfosapp"
export cfos_image="interbeing/fos:v7231x86"
export app_image="praqma/network-multitool"
export policymanagerimage="interbeing/kubectl-cfos:gke_demo_v2"
export internet_webf_url="https://xoso.com.vn"
export serices_ipv4_cidr="10.144.0.0/20"
export cluster_ipv4_cidr="10.140.0.0/14"
export app_deployment_label="multitool01"
export cfos_label="fos"
export cfos_data_host_path="/home/kubernetes/cfosdata"
export configmap_policy_id="300"
export gatekeeper_policy_id="200"
