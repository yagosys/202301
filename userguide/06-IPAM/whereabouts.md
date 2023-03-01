#https://github.com/k8snetworkplumbingwg/whereabouts

```
install 
git clone https://github.com/k8snetworkplumbingwg/whereabouts && cd whereabouts
kubectl apply \
    -f doc/crds/daemonset-install.yaml \
    -f doc/crds/whereabouts.cni.cncf.io_ippools.yaml \
    -f doc/crds/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml


sample config
1. bridge cni use whereabouts ipam
{
            "cniVersion": "0.4.0",
            "plugins": [
              {
                "name": "cfosdefaultcni5",
                "type": "bridge",
                "isGateway": false,
                "bridge": "cni5",
                "ipMasq": false,
                "ipam": {
                    "type": "whereabouts",
                    "range": "10.1.128.0/24",
                    "gateway": "10.1.128.2",
                    "log_file": "/tmp/whereabouts.log",
                    "log_level": "debug",
                    "routes": [
                      {
                        "dst": "10.96.0.0/12",
                        "gw": "10.1.128.1"
                      },
                      {
                        "dst": "10.0.0.2/32",
                        "gw": "10.1.128.1"
                      }
                    ],
                    "exclude": [
                      "10.1.128.1/32",
                      "10.1.128.2/32",
                      "10.1.128.254/32"
                    ]
                }
             }
            ]
}

2. flannel cni use whereabouts ipam

{
  "cniVersion": "0.4.0",
  "type": "flannel",
  "name": "flannel1",
  "ipam": {
  "type": "whereabouts",
     "range": "10.244.1.0/24",
     "gateway": "10.244.1.1",
     "log_file": "/tmp/whereabouts.log",
     "log_level": "debug",
     "routes": [
        {
          "dst": "10.96.0.0/12",
          "gw": "10.244.1.1"
        },
        { "dst": "10.0.0.2/32",
          "gw": "10.244.1.1"
        }
     ],
     "exclude": [
        "10.244.1.1/32"
     ]
  },
  "delegate": {
    "isDefaultGateway": true,
    "hairpinMode": true
  }
}
