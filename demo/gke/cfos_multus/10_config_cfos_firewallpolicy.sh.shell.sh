policy_id="$configmap_policy_id"
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"
filename="10_config_cfos_firewallpolicy.sh.shell.sh.yml.sh"

cat << OUTER_EOF > $filename
cat << EOF | kubectl create -f  -
apiVersion: v1
kind: ConfigMap
metadata:
  name: foscfgfirewallpolicy
  labels:
      app: $cfos_label
      category: config
data:
  type: partial
  config: |-
    config firewall policy
           edit "$configmap_policy_id"
               set utm-status enable
               set name "pod_to_internet_HTTPS_HTTP"
               set srcintf any
               set dstintf eth0
               set srcaddr all
               set dstaddr all
               set service HTTPS HTTP PING DNS
               set ssl-ssh-profile "deep-inspection"
               set ips-sensor "default"
               set webfilter-profile "default"
               set av-profile "default"
               set nat enable
               set logtraffic all
           next
       end
EOF
kubectl get cm foscfgfirewallpolicy -o yaml 
OUTER_EOF
chmod +x $filename
./$filename
