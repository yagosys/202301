- overview

this demo show how to use gatekeeper to convert egress network policy and apply to cfos as network firewall policy

here is how it work.

when kube-API server receive API request for create egress network policy, the API server admission controller will send request (as admission-review) to WEB HOOK which is gatekeeper, then gatekeeper use OPA to evalute the request. during evalation, gatekeep use http.send send request to cfos via restful API interface to config firewall policy on cfos.  then send back the deny back to API server. as a result, cfos will be configured with egress firewall policy, the egress network policy will not be created.

the cfos restful API does not have authentation. and the clusterIP for resultAPI has fixed IP address. 
the egress network policy must have label "cfosegressfirewallpolicy" applied. other opa will ignore this networkpolicy.


- install gatekeeper

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

after deployment. you shall able to see that gatekeeper has been installed.

```
ubuntu@ip-10-0-1-100:~/opa$ kubectl get all -n gatekeeper-system
NAME                                                 READY   STATUS    RESTARTS   AGE
pod/gatekeeper-audit-6bf659f755-mcphk                1/1     Running   2          35h
pod/gatekeeper-controller-manager-7f6cccd9cb-7lx4j   1/1     Running   1          35h
pod/gatekeeper-controller-manager-7f6cccd9cb-95xgv   1/1     Running   1          35h
pod/gatekeeper-controller-manager-7f6cccd9cb-nb8g5   1/1     Running   1          35h

NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/gatekeeper-webhook-service   ClusterIP   10.103.186.136   <none>        443/TCP   35h

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gatekeeper-audit                1/1     1            1           35h
deployment.apps/gatekeeper-controller-manager   3/3     3            3           35h

NAME                                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/gatekeeper-audit-6bf659f755                1         1         1       35h
replicaset.apps/gatekeeper-controller-manager-7f6cccd9cb   3         3         3       35h
ubuntu@ip-10-0-1-100:~/opa$
```

- create constraintemplate

```
cat << EOF | kubectl apply -f 
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8segressnetworkpolicytocfosutmpolicy
spec:
  crd:
    spec:
      names:
        kind: K8sEgressNetworkPolicyToCfosUtmPolicy
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          properties:
            message:
              type: string
            podcidr:
              type: string
            cfosegressfirewallpolicy:
              type: string
            outgoingport:
              type: string
            utmstatus:
              type: string
            ipsprofile:
              type: string
            avprofile:
              type: string
            sslsshprofile:
              type: string
            action:
              type: string
            srcintf:
              type: string
            firewalladdressapiurl:
              type: string
            firewallpolicyapiurl:
              type: string

  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8segressnetworkpolicytocfosutmpolicy
        import future.keywords.every
          pod_egress_has_http_port {
             input.review.object.spec.egress[_].ports[_].port == 80
          }
          pod_egress_has_https_port {
            input.review.object.spec.egress[_].ports[_].port == 443
          }

          pod_egress_has_dns_port {
            input.review.object.spec.egress[_].ports[_].port == 53
            input.review.object.spec.egress[_].ports[_].protocol == "UDP"
          }
          service_dns = "DNS" {
            pod_egress_has_dns_port
          }

          service_http = "HTTP" {
            pod_egress_has_http_port
          }

          service_https = "HTTPS" {
            pod_egress_has_https_port
          }
          violation[{
            "msg" : msg
          }] {
          input.review.object.metadata.labels.app==input.parameters.label
          protocol := input.review.object.spec.egress[_].ports[_].protocol
          dstipblock :=  input.review.object.spec.egress[_].to[_].ipBlock.cidr
          utm := input.parameters.utmstatus
          utm == "enable"
          ipsprofile := input.parameters.ipsprofile
          avprofile := input.parameters.avprofile
          sslsshprofile := input.parameters.sslsshprofile
          action  := input.parameters.action
          srcintf := input.parameters.srcintf
          token := "4252d60858fb48"
          podcidr := input.parameters.podcidr
          outgoingport := input.parameters.outgoingport
          firewalladdressapiurl := input.parameters.firewalladdressapiurl
          firewallpolicyapiurl := input.parameters.firewallpolicyapiurl
          myip := http.send({
           "method": "GET",
           "url": "https://ipinfo.io/",
           "headers": {
           "Authorization": sprintf("Bearer %s", [token])
           }
          }).body.ip

          headers := {
           "Content-Type": "application/json",
          }

          srcaddrbody := {
            "data": {"name": "srcipblock", "subnet": podcidr}
          }
          dstaddrbody := {
            "data":  {"name": "dstipblock", "subnet": dstipblock}
          }

          srcaddrresp := http.send({
            "method": "POST",
            "url": firewalladdressapiurl,
            "headers": headers,
            "body": srcaddrbody
          })

          dstaddrresp := http.send({
            "method": "POST",
            "url": firewalladdressapiurl,
            "headers": headers,
            "body": dstaddrbody
          })

          body := {
            "data": { "policyid":"20",
                      "name": "pod-egress-traffic",
                      "utm-status": "enable",
                      "srcintf": [{"name": srcintf}],
                      "dstintf": [{"name": outgoingport}],
                      "srcaddr": [{"name": "srcipblock"}],
                      "dstaddr": [{"name": "dstipblock" }],
                      "service": [{"name": service_https},{"name":service_http}, {"name":service_dns}],
                      "av-profile": avprofile,
                      "ips-sensor": ipsprofile,
                      "action": "accept",
                      "logtraffic": "all",
                      "nat": "enable",
                      "ssl-ssh-profile": sslsshprofile

             }
          }
          resp := http.send({
            "method": "POST",
            "url":firewallpolicyapiurl,
            "headers": headers,
            "body": body
          })


          msg :=sprintf("\n{\n set srcintf =%v\nset av-profile=%v\nset ips-sensor=%v\nset ssl-ssh-profile %v\nset dstintf %v\nset dstaddr %v\nset service =%v%v%v\nset srcaddr %v\nset action %
v\n srcadd:%v\n dstaddr:%v\n firewallpolicy:%v \n} ", [
          srcintf,
          avprofile,
          ipsprofile,
          sslsshprofile,
          outgoingport,
          dstipblock,
          service_https,
          service_http,
          service_dns,
          podcidr,
          action,
          srcaddrresp.status_code,
          dstaddrresp.status_code,
          resp.status_code,
         ])
        }

EOF 
```

- create constraint


```
cat << EOF | kubectl create -f - 
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sEgressNetworkPolicyToCfosUtmPolicy
metadata:
  name: cfosnetworkpolicy
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: ["networking.k8s.io"]
        kinds: ["NetworkPolicy"]
  parameters:
    firewalladdressapiurl : "http://10.100.233.36/api/v2/cmdb/firewall/address"
    firewallpolicyapiurl : "http://10.100.233.36/api/v2/cmdb/firewall/policy"
    message: "deny any any"
    podcidr: "10.85.0.0/16"
    label: "cfosegressfirewallpolicy"
    outgoingport: "eth0"
    utmstatus: "enable"
    ipsprofile: "default"
    avprofile: "default"
    sslsshprofile: "deep-inspection"
    action: "permit"
    srcintf: "any"
EOF 
```

- create egress networkpolicy for demo

```
cat <<EOF | kubectl create -f - 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test
  labels:
    app: cfosegressfirewallpolicy
spec:
  podSelector:
    matchLabels:
      app: database
  egress:
  - to:
    - ipBlock:
        cidr: 200.0.0.0/24
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
    - protocol: UDP
      port: 53
EOF 
```

- deploy demo networkpolicy

```
ubuntu@ip-10-0-1-100:~/opa$ kubectl create -f networkPolicySameple.yaml
Error from server (Forbidden): error when creating "networkPolicySameple.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [cfosnetworkpolicy]
{
 set srcintf =any
set av-profile=default
set ips-sensor=default
set ssl-ssh-profile deep-inspection
set dstintf eth0
set dstaddr 200.0.0.0/24
set service =HTTPSHTTPDNS
set srcaddr 10.85.0.0/16
set action permit
 srcadd:200
 dstaddr:200
 firewallpolicy:200
}
```

the cfos now configured with firewall policy. the states_coud 200 means the config is succesful. 

```
FOS Container (address) # edit dstipblock

FOS Container (dstipblock) # show

config firewall address
    edit "dstipblock"
        set subnet 200.0.0.0 255.255.255.0
    next
end

config firewall address
    edit "srcipblock"
        set subnet 10.85.0.0 255.255.0.0
    next
end

FOS Container (policy) # edit 20

FOS Container (20) # show
config firewall policy
    edit "20"
        set utm-status enable
        set name "pod-egress-traffic"
        set srcintf any
        set dstintf eth0
        set srcaddr srcipblock
        set dstaddr dstipblock
        set service HTTPS HTTP DNS
        set ssl-ssh-profile "deep-inspection"
        set av-profile "default"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
end


```

