question:
1. create a linux net namespace 

2. create a macvlan or bridge cni config file with host-local as ipam.

you may access https://www.cni.dev/plugins/current/main/macvlan/ for reference. 

3. use cnitool to add an veth to net namespace 

4. exec into net namespace and check ip address




