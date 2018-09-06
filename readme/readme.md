
# Validating EVPN traffic flows

## Validate IP neighbor table

Validate entry in bridge table
```
cumulus@leaf01:mgmt-vrf:~$ net show bridge macs

VLAN      Master  Interface  MAC                TunnelDest  State      Flags          LastSeen
--------  ------  ---------  -----------------  ----------  ---------  -------------  ---------------
100       bridge  bridge     44:39:39:ff:00:10              permanent                 16:07:20
100       bridge  bridge     50:6b:4b:95:90:98              permanent                 1 day, 16:50:28
100       bridge  swp1s0     0c:c4:7a:1d:f3:0d                                        00:00:11
100       bridge  swp1s1     00:12:55:03:3a:10                                        00:00:11
100       bridge  vni100     7c:fe:90:bf:1a:71                         offload        10:00:28
100       bridge  vni100     90:e2:ba:98:4c:f1                         offload        10:00:28
100       bridge  vni100     ac:1f:6b:89:a3:af                         offload        10:00:28
200       bridge  bridge     44:39:39:ff:00:20              permanent                 16:07:20
200       bridge  bridge     50:6b:4b:95:90:98              permanent                 17:34:21
200       bridge  swp1s3     e8:ea:6a:06:1b:d5                                        00:00:11
4001      bridge  bridge     44:39:39:ff:40:94              permanent                 16:48:57
4001      bridge  bridge     50:6b:4b:95:90:98              permanent                 1 day, 16:50:28
4001      bridge  vxlan4001  2e:84:d8:8b:3d:bb                         offload        16:15:26
4001      bridge  vxlan4001  44:39:39:ff:40:95                         offload        10:00:28
untagged          bridge     44:39:39:ff:00:10              permanent  self           never
untagged          bridge     44:39:39:ff:00:20              permanent  self           never
untagged          bridge     44:39:39:ff:40:94              permanent  self           never
untagged          vlan100    44:39:39:ff:00:10              permanent  self           never
untagged          vlan200    44:39:39:ff:00:20              permanent  self           never
untagged          vni100     00:00:00:00:00:00  10.0.0.12   permanent  self           10:00:30
untagged          vni100     7c:fe:90:bf:1a:71  10.0.0.12              self, offload  10:00:30
untagged          vni100     90:e2:ba:98:4c:f1  10.0.0.12              self, offload  10:00:30
untagged          vni100     ac:1f:6b:89:a3:af  10.0.0.12              self, offload  10:00:30
untagged          vxlan4001  2e:84:d8:8b:3d:bb  10.0.0.41              self, offload  16:15:26
untagged          vxlan4001  44:39:39:ff:40:95  10.0.0.12              self, offload  10:00:30
untagged  bridge  swp1s0     50:6b:4b:95:90:98              permanent                 1 day, 16:50:28
untagged  bridge  swp1s1     50:6b:4b:95:90:99              permanent                 1 day, 16:50:28
untagged  bridge  swp1s2     50:6b:4b:95:90:9a              permanent                 1 day, 16:50:28
untagged  bridge  swp1s3     50:6b:4b:95:90:9b              permanent                 1 day, 16:50:28
untagged  bridge  vni100     4e:9e:59:31:28:08              permanent                 1 day, 20:49:09
untagged  bridge  vni200     e2:49:2c:3a:3e:c9              permanent                 17:34:21
untagged  bridge  vxlan4001  44:39:39:ff:40:94              permanent                 16:15:26
```

Validate entry in neighbor table:
```
cumulus@leaf01:mgmt-vrf:~$ ip neighbor show
185.2.136.245 dev vlan100 lladdr 0c:c4:7a:1d:f3:0d REACHABLE
169.254.0.1 dev swp16 lladdr 24:8a:07:f2:6c:98 PERMANENT
10.255.6.250 dev eth0 lladdr 00:50:56:a8:03:94 REACHABLE
185.2.136.245 dev vlan100-v0 lladdr 0c:c4:7a:1d:f3:0d STALE
185.2.136.250 dev vlan100 lladdr ac:1f:6b:89:a3:af offload NOARP
10.0.0.12 dev vlan4001 lladdr 44:39:39:ff:40:95 offload NOARP
10.0.0.41 dev vlan4001 lladdr 2e:84:d8:8b:3d:bb offload NOARP
185.2.136.248 dev vlan100-v0 lladdr 7c:fe:90:bf:1a:71 STALE
185.2.136.247 dev vlan100 lladdr 90:e2:ba:98:4c:f1 offload NOARP
185.2.136.248 dev vlan100 lladdr 7c:fe:90:bf:1a:71 offload NOARP
10.255.6.1 dev eth0 lladdr 00:50:56:a8:da:e7 REACHABLE
169.254.0.1 dev swp15 lladdr 24:8a:07:83:1a:18 PERMANENT
46.23.68.83 dev vlan200 lladdr e8:ea:6a:06:1b:d5 REACHABLE
fe80::268a:7ff:fef2:6c98 dev swp16 lladdr 24:8a:07:f2:6c:98 router REACHABLE
fe80::526b:4bff:feed:7af2 dev eth0 lladdr 50:6b:4b:ed:7a:f2 STALE
fe80::526b:4bff:feed:79ba dev eth0 lladdr 50:6b:4b:ed:79:ba router STALE
fe80::268a:7ff:fe83:1a18 dev swp15 lladdr 24:8a:07:83:1a:18 router REACHABLE
```


Look at VNIs in EVPN:
```
cumulus@leaf01:mgmt-vrf:~$ net show evpn vni
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF
10200      L2   vni200                1        5        0               public
10100      L2   vni100                5        8        1               public
104001     L3   vxlan4001             2        2        n/a             public
```


Make sure neighbor entries are being pulled into EVPN:
```
cumulus@leaf01:mgmt-vrf:~$ net show evpn arp-cache vni 10100
Number of ARPs (local and remote) known for this VNI: 8
IP                        Type   MAC               Remote VTEP
185.2.136.250             remote ac:1f:6b:89:a3:af 10.0.0.12
fe80::4639:39ff:feff:10   local  44:39:39:ff:00:10
185.2.136.247             remote 90:e2:ba:98:4c:f1 10.0.0.12
185.2.136.243             local  50:6b:4b:95:90:98
185.2.136.245             local  0c:c4:7a:1d:f3:0d
185.2.136.241             local  44:39:39:ff:00:10
185.2.136.248             remote 7c:fe:90:bf:1a:71 10.0.0.12
fe80::526b:4bff:fe95:9098 local  50:6b:4b:95:90:98
```


Check to make sure all neighbor and route entries are being pulled into EVPN:
```
cumulus@leaf01:mgmt-vrf:~$ net show bgp l2vpn evpn vni
Advertise Gateway Macip: Disabled
Advertise All VNI flag: Enabled
Number of L2 VNIs: 2
Number of L3 VNIs: 1
Flags: * - Kernel
  VNI        Type RD                    Import RT                 Export RT                 Tenant VRF
* 10200      L2   10.0.0.11:4           65011:10200               65011:10200              public
* 10100      L2   10.0.0.11:2           65011:10100               65011:10100              public
* 104001     L3   185.2.136.243:3       65011:104001              65011:104001             public
```

```
cumulus@leaf01:mgmt-vrf:~$ net show bgp l2vpn evpn route rd 10.0.0.11:2
EVPN type-2 prefix: [2]:[ESI]:[EthTag]:[MAClen]:[MAC]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[ESI]:[EthTag]:[IPlen]:[IP]

BGP routing table entry for 10.0.0.11:2:[2]:[0]:[0]:[48]:[00:12:55:03:3a:10]
Paths: (1 available, best #1)
  Advertised to non peer-group peers:
  spine01(swp15) spine02(swp16)
  Route [2]:[0]:[0]:[48]:[00:12:55:03:3a:10] VNI 10100/104001
  Local
    10.0.0.11 from 0.0.0.0 (10.0.0.11)
      Origin IGP, localpref 100, weight 32768, valid, sourced, local, bestpath-from-AS Local, best
      Extended Community: ET:8 RT:65011:10100 RT:65011:104001 Rmac:44:39:39:ff:40:94
      AddPath ID: RX 0, TX 27512
      Last update: Wed Sep  5 16:46:13 2018

BGP routing table entry for 10.0.0.11:2:[2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d]
Paths: (1 available, best #1)
  Advertised to non peer-group peers:
  spine01(swp15) spine02(swp16)
  Route [2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d] VNI 10100/104001
  Local
    10.0.0.11 from 0.0.0.0 (10.0.0.11)
      Origin IGP, localpref 100, weight 32768, valid, sourced, local, bestpath-from-AS Local, best
      Extended Community: ET:8 RT:65011:10100 RT:65011:104001 Rmac:44:39:39:ff:40:94
      AddPath ID: RX 0, TX 27510
      Last update: Wed Sep  5 16:46:13 2018

BGP routing table entry for 10.0.0.11:2:[2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d]:[32]:[185.2.136.245]
Paths: (1 available, best #1)
  Advertised to non peer-group peers:
  spine01(swp15) spine02(swp16)
  Route [2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d]:[32]:[185.2.136.245] VNI 10100/104001
  Local
    10.0.0.11 from 0.0.0.0 (10.0.0.11)
      Origin IGP, localpref 100, weight 32768, valid, sourced, local, bestpath-from-AS Local, best
      Extended Community: ET:8 RT:65011:10100 RT:65011:104001 Rmac:44:39:39:ff:40:94
      AddPath ID: RX 0, TX 27514
      Last update: Wed Sep  5 16:46:13 2018

BGP routing table entry for 10.0.0.11:2:[3]:[0]:[32]:[10.0.0.11]
Paths: (1 available, best #1)
  Advertised to non peer-group peers:
  spine01(swp15) spine02(swp16)
  Route [3]:[0]:[32]:[10.0.0.11] VNI 10100
  Local
    10.0.0.11 from 0.0.0.0 (10.0.0.11)
      Origin IGP, localpref 100, weight 32768, valid, sourced, local, bestpath-from-AS Local, best
      Extended Community: ET:8 RT:65011:10100
      AddPath ID: RX 0, TX 27506
      Last update: Wed Sep  5 16:12:42 2018
      PMSI Tunnel Type: No info


Displayed 4 prefixes (4 paths) with this RD
```

Look at global routing table to validate all routes are propogated into VXLAN:
```
cumulus@leaf01:mgmt-vrf:~$ net show bgp l2vpn evpn route | more
BGP table version is 224, local router ID is 10.0.0.11
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-2 prefix: [2]:[ESI]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[ESI]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.0.0.11:2
*> [2]:[0]:[0]:[48]:[00:12:55:03:3a:10]
                    10.0.0.11                          32768 i
*> [2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d]
                    10.0.0.11                          32768 i
*> [2]:[0]:[0]:[48]:[0c:c4:7a:1d:f3:0d]:[32]:[185.2.136.245]
                    10.0.0.11                          32768 i
*> [3]:[0]:[32]:[10.0.0.11]
                    10.0.0.11                          32768 i
Route Distinguisher: 10.0.0.11:4
*> [2]:[0]:[0]:[48]:[e8:ea:6a:06:1b:d5]
                    10.0.0.11                          32768 i
*> [2]:[0]:[0]:[48]:[e8:ea:6a:06:1b:d5]:[32]:[46.23.68.83]
                    10.0.0.11                          32768 i
*> [3]:[0]:[32]:[10.0.0.11]
                    10.0.0.11                          32768 i
Route Distinguisher: 10.0.0.12:2
*  [2]:[0]:[0]:[48]:[7c:fe:90:bf:1a:71]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[7c:fe:90:bf:1a:71]
                    10.0.0.12                              0 65020 65012 i
*  [2]:[0]:[0]:[48]:[7c:fe:90:bf:1a:71]:[32]:[185.2.136.248]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[7c:fe:90:bf:1a:71]:[32]:[185.2.136.248]
                    10.0.0.12                              0 65020 65012 i
*  [2]:[0]:[0]:[48]:[90:e2:ba:98:4c:f1]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[90:e2:ba:98:4c:f1]
                    10.0.0.12                              0 65020 65012 i
*  [2]:[0]:[0]:[48]:[90:e2:ba:98:4c:f1]:[32]:[185.2.136.247]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[90:e2:ba:98:4c:f1]:[32]:[185.2.136.247]
                    10.0.0.12                              0 65020 65012 i
*  [2]:[0]:[0]:[48]:[ac:1f:6b:89:a3:af]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[ac:1f:6b:89:a3:af]
                    10.0.0.12                              0 65020 65012 i
*  [2]:[0]:[0]:[48]:[ac:1f:6b:89:a3:af]:[32]:[185.2.136.250]
                    10.0.0.12                              0 65020 65012 i
*> [2]:[0]:[0]:[48]:[ac:1f:6b:89:a3:af]:[32]:[185.2.136.250]
                    10.0.0.12                              0 65020 65012 i
*  [3]:[0]:[32]:[10.0.0.12]
                    10.0.0.12                              0 65020 65012 i
*> [3]:[0]:[32]:[10.0.0.12]
                    10.0.0.12                              0 65020 65012 i
Route Distinguisher: 10.0.0.41:2
*  [5]:[0]:[0]:[0]:[0.0.0.0]
                    10.0.0.41                              0 65020 65041 ?
*> [5]:[0]:[0]:[0]:[0.0.0.0]
                    10.0.0.41                              0 65020 65041 ?
*  [5]:[0]:[0]:[8]:[10.0.0.0]
                    10.0.0.41                              0 65020 65041 ?
*> [5]:[0]:[0]:[8]:[10.0.0.0]
                    10.0.0.41                              0 65020 65041 ?
*  [5]:[0]:[0]:[12]:[172.16.0.0]
                    10.0.0.41                              0 65020 65041 ?
*> [5]:[0]:[0]:[12]:[172.16.0.0]
                    10.0.0.41                              0 65020 65041 ?
*  [5]:[0]:[0]:[16]:[10.19.0.0]
                    10.0.0.41                              0 65020 65041 ?
*> [5]:[0]:[0]:[16]:[10.19.0.0]
                    10.0.0.41                              0 65020 65041 ?
```

Check VRF BGP route tables
```
cumulus@leaf01:mgmt-vrf:~$ net show bgp vrf public

show bgp vrf public ipv4 unicast
================================
BGP table version is 3425, local router ID is 185.2.136.243
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 0.0.0.0          10.0.0.41                              0 65020 65041 ?
*                   10.0.0.41                              0 65020 65041 ?
```

Check VRF routing table:
```
cumulus@leaf01:mgmt-vrf:~$ net show route vrf public | more

show ip route vrf public
=========================
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR,
       > - selected route, * - FIB route


VRF public:
B>* 0.0.0.0/0 [20/0] via 10.0.0.41, vlan4001 onlink, 16:25:04
K * 0.0.0.0/0 [255/8192] unreachable (ICMP unreachable), 1d20h58m
```

