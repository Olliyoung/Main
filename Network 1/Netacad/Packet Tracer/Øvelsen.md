
sh version: udgiver SW Image / IOS Filename: C2960-LANBASEK9-M


Switch Hostnames:
S1 | Fastethernet 0/1 | 192.168.0.1 | vlan1
S2 | Fastethernet 0/2 | 192.168.0.2 | vlan1

PC:
PC1 | Fastethernet 0/10 | 192.168.0.10 | vlan1
PC2 | Fastethernet 0/20 | 192.168.0.20 | vlan1


IP Plan:

| IP Addresses | Subnet Mask   | Device | Hostname |
| ------------ | ------------- | ------ | -------- |
| 192.168.0.1  | 255.255.255.0 | Switch | S1       |
| 192.168.0.2  | 255.255.255.0 | Switch | S2       |
| 192.168.0.10 | 255.255.255.0 | PC     | PC1      |
| 192.168.0.20 | 255.255.255.0 | PC     | PC2      |

Kommandoer:

Remever to "enable"

Configure terminal:
"conf t / configure terminal"

Gem ændringer:
"copy running-config startup-config / wr"

Edit interface:
"interface "xxxxx"

Make it not shutdown
"no shutdown"

