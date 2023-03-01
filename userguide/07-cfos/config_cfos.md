## cfos can be configured use cfos cli 

```
ubuntu@ip-10-0-1-100:~$ kubectl exec -it fos-deployment-chqxj -- fcnsh
FOS Container # 
```
- apply license

```
FOS Container # execute import-vmlicense 
```

- check cFOS liense and status 

```
FOS Container # diagnose sys license
FOS Container # diagnose sys status 
```
- update latest signiture from fortiguard 

```
FOS Container # execute  update-now

2023/03/01 02:23:39 Host UUID:
2023/03/01 02:23:39 Connecting to globalupdate.fortinet.net:443
2023/03/01 02:23:39 Connected to: 173.243.140.6:443.
2023/03/01 02:23:39  TLS version: 304. Cipher: TLS_AES_256_GCM_SHA384 Resumed: false
2023/03/01 02:23:39 Setup: Protocol=3.0|Command=Setup|Firmware=FCN100-FW-7.2-0231|SerialNumber=FGVMULTM23000044|Connection=Internet|Address=10.244.2.24|Language=en-US|TimeZone=-8|UpdateMethod=0
2023/03/01 02:23:39 FCPR: Protocol=3.0|Response=202|Firmware=FPT033-FW-6.8-0181|SerialNumber=FPT-FGT-DELL1203|Server=FDSG|Persistent=false|PEER_IP=18.141.240.242
2023/03/01 02:23:39 public IP: 18.141.240.242
2023/03/01 02:23:39 response code: 202
2023/03/01 02:23:39 what to do next? next
2023/03/01 02:23:40 Connected to: 173.243.140.6:443.
2023/03/01 02:23:40  TLS version: 304. Cipher: TLS_AES_256_GCM_SHA384 Resumed: false
2023/03/01 02:23:40 Items to update: 07000000FFDB01107-00007.03077-2302271738*07000000CRDB00000-00001.00040-2301111910*07000000APDB00105-00022.00503-2302280243*07000000NIDS02405-00022.00503-2302280243*07000000MUDB00103-00004.00634-2302281701*07000000FLDB00201-00091.01006-2302281631*07000000IPGO00000-00003.00165-20230227230433*
2023/03/01 02:23:41 got object FCPR 0 FCP Response Object
2023/03/01 02:23:41 FCPR response Protocol=3.2|Response=300|Firmware=FPT033-FW-6.8-0181|SerialNumber=FPT-FGT-DELL1203|Server=FDSG|Persistent=false|PEER_IP=18.141.240.242|ResponseItem=07000000FFDB01107:204*07000000CRDB00000:204*07000000APDB00105:204*07000000NIDS02405:204*07000000MUDB00103:204*07000000FLDB00201:200*07000000IPGO00000:204
2023/03/01 02:23:41 Got response items 07000000FFDB01107:204*07000000CRDB00000:204*07000000APDB00105:204*07000000NIDS02405:204*07000000MUDB00103:204*07000000FLDB00201:200*07000000IPGO00000:204
2023/03/01 02:23:41 response code 300
2023/03/01 02:23:41 got object FLDB 2 FGT FlowDB
2023/03/01 02:23:41 saving db: virfldb
2023/03/01 02:23:41 what to do next? continue
2023/03/01 02:23:42 Connected to: 173.243.140.6:443.
2023/03/01 02:23:42  TLS version: 304. Cipher: TLS_AES_256_GCM_SHA384 Resumed: false
2023/03/01 02:23:42 Items to update: 07000000FFDB01107-00007.03077-2302271738*07000000CRDB00000-00001.00040-2301111910*07000000APDB00105-00022.00503-2302280243*07000000NIDS02405-00022.00503-2302280243*07000000MUDB00103-00004.00634-2302281701*07000000FLDB00201-00091.01007-2302281731*07000000IPGO00000-00003.00165-20230227230433*
2023/03/01 02:23:42 got object FCPR 0 FCP Response Object
2023/03/01 02:23:42 FCPR response Protocol=3.2|Response=300|Firmware=FPT033-FW-6.8-0181|SerialNumber=FPT-FGT-DELL1203|Server=FDSG|Persistent=false|PEER_IP=18.141.240.242|ResponseItem=07000000FFDB01107:204*07000000CRDB00000:204*07000000APDB00105:204*07000000NIDS02405:204*07000000MUDB00103:204*07000000FLDB00201:204*07000000IPGO00000:204
2023/03/01 02:23:42 Got response items 07000000FFDB01107:204*07000000CRDB00000:204*07000000APDB00105:204*07000000NIDS02405:204*07000000MUDB00103:204*07000000FLDB00201:204*07000000IPGO00000:204
2023/03/01 02:23:42 response code 300
2023/03/01 02:23:42 everything is up-to-date
2023/03/01 02:23:42 what to do next? stop
2023/03/01 02:23:42 DB updates notified!
FOS Container #

```
- config firewall policy

FOS Container # config firewall policy

FOS Container (policy) # show
config firewall policy
    edit "3"
        set utm-status enable
        set name "pod_to_internet_HTTPS_HTTP"
        set srcintf any
        set dstintf eth0
        set srcaddr all
        set dstaddr all
        set service HTTPS HTTP PING DNS
        set ssl-ssh-profile "deep-inspection"
        set av-profile "default"
        set webfilter-profile "default"
        set ips-sensor "default"
        set nat enable
        set logtraffic all
    next
end
```
- display events log

```
execute  log filter  device  disk
FOS Container # execute  log filter  category

 0: traffic
 1: event
 2: utm-virus
 3: utm-webfilter
 4: utm-ips
 9: utm-dlp
10: utm-app-ctrl
15: utm-dns
17: utm-ssl
19: utm-file-filter
FOS Container # execute  log filter  category 0

FOS Container # execute  log display
<Enter>

tion=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0
date=2023-02-27 time=02:58:39 eventtime=1677466719 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.3 srcport=50234 dstip=89.238.73.97 dstport=443 sessionid=1832333291 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0 srcintf="net1" dstintf="eth0" utmaction="block"
date=2023-02-27 time=02:58:39 eventtime=1677466719 tz="+0000" logid="0000000013" type="traffic" subtype="forward" level="notice" srcip=10.1.128.4 srcport=48242 dstip=89.238.73.97 dstport=443 sessionid=4210933913 proto=6 action="accept" policyid=3 service="HTTPS" trandisp="noop" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 rcvdpkt=0 srcintf="net1" dstintf="eth0" utmaction="block"
```


