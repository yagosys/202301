- what is cfos 
Cfos is container version of fortios. it meet the oci standard, so can be run under docker, containered, and crio runtime.

cfos offer l7 security feature such as IPS, DNS filter, Web filter, SSL deep inspection etc., also cfos provide real time updated security update from fortiguard. These updates help detect and prevent cyberattacks, block malicious traffic, and provide secure access to resources.

when deploy cfos in k8s, it can protect IP traffic from POD egress to internet and also can protect east-west traffic between different POD CIDR subnet. this is enabled by add multus CNI,
 with multus, cfos can use one interface for control plane communication, such as access to k8s API, expose serice to external world etc., while use other interface dedicated for inspect traffic from other POD. to seperate the control plane traffic with data plane traffic. the additional interface can be associated with high performance NIC such as the interface that has SRIOV enabled for high performance and lowest latency. one of the use cas is POD egress security  

- Use case : POD egress security 

Pod egress security is important because it helps organizations protect their networks and data from potential threats that may come from outgoing traffic from pods in their kubernetes clusters. Here are some reasons why pod egress security is crucial:

Prevent data exfiltration: Without proper egress security controls, a malicious actor could potentially use an application running in a pod to exfiltrate sensitive data from the cluster.

Control outgoing traffic: By restricting egress traffic from pods to specific IP addresses or domains, organizations can prevent unauthorized communication with external entities and control access to external resources.

Comply with regulatory requirements: Many regulations require organizations to implement controls around outgoing traffic to ensure compliance with data privacy and security regulations. Implementing pod egress security controls can help organizations meet these requirements.

Prevent malware infections: A pod that is compromised by malware could use egress traffic to communicate with external command and control servers, leading to further infections and data exfiltration. Egress security controls can help prevent these types of attacks.

Overall, implementing pod egress security controls is an important part of securing kubernetes clusters and ensuring the integrity, confidentiality, and availability of organizational data.
in this use case , application can route traffic with dedicated network which created by multus to cfos POD. cfos POD inspect the packet for IPS attack, URL filter, DNS filter etc, if it's SSL encrpyted. cFOS also do deep packet inspection. 

