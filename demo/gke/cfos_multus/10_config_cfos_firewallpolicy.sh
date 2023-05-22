policy_id="$configmap_policy_id"
[[ -z $cfos_label ]] && cfos_label="fos"
[[ -z $configmap_policy_id ]] && configmap_policy_id="300"
file="configmapfirewallpolicy.yml"
cat << EOF > $file
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
kubectl create -f $file 
