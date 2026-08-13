
sh version: udgiver SW Image / IOS Filename: C2960-LANBASEK9-M


Switch Hostnames:
S1 | Fastethernet 0/1 | 192.168.0.101 | vlan1
S2 | Fastethernet 0/2 | 192.168.0.102 | vlan1

PC:
PC1 | Fastethernet 0/10 | 192.168.0.10
PC2 | Fastethernet 0/20 | 192.168.0.20


IP Plan:

| IP Addresses  | Subnet Mask   | Device | Hostname |
| ------------- | ------------- | ------ | -------- |
| 192.168.0.101 | 255.255.255.0 | Switch | S1       |
| 192.168.0.102 | 255.255.255.0 | Switch | S2       |
| 192.168.0.10  | 255.255.255.0 | PC     | PC1      |
| 192.168.0.20  | 255.255.255.0 | PC     | PC2      |

Kommandoer:

S1 192.168.0.101 | S2 192.168.0.102 | PC1 192.168.0.10 | PC2 192.168.0.20 IPs must all be different:

privileged mode: **enable**

config mode: **conf t**

set name: **hostname S1**

enable password: **enable secret pass**

needed for RSA: **ip domain-name OYL.com**

make SSH key: **crypto key generate rsa**

local user: **username admin secret pass**

remote lines: **line vty 0 15**

only SSH: **transport input ssh**

use local user: **login local**

management: **interface vlan 1**

unique IP: **ip address 192.168.0.101 255.255.255.0**

turn on: **no shutdown**

same on S2 but hostname S2 and IP 192.168.0.102:

turn ports on: interface (xxxxx) no shutdown

save: wr