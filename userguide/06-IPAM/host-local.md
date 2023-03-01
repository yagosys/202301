#https://www.cni.dev/plugins/current/ipam/host-local/#:~:text=host%2Dlocal%20IPAM%20plugin%20allocates,of%20multiple%20(disjoint)%20subnets.
```
host-local can be chained with other cni plugins for IP address allocation as well as route config etc.,

here is an example of bridge cni use host-local, flannel can also use host-local. 
{
    "cniVersion": "0.3.1",
    "name": "cfosdefaultcni5",
       "type": "bridge",
       "bridge": "cni5",
       "isGateway": true,
       "ipMasq": true,
       "hairpinMode": true,
       "ipam": {
           "type": "host-local",
           "routes": [
               { "dst": "10.96.0.0/12","gw": "10.86.0.1" },
               { "dst": "10.0.0.2/32", "gw": "10.86.0.1" }
           ],
           "ranges": [
               [{ "subnet": "10.86.0.0/16" }]
           ]
       }
}
```
